# encoding: utf-8
module Amadeus
  module Response

    module FareMasterPricerTravelBoardSearchSax

      # ======
      class ErrorMessage
        include SAXMachine
        element :description, :as => :message
        element :error, :as => :code
      end
      # ======

      class SegmentFlightRef
        include SAXMachine

        elements :refQualifier, :as => :ref_qualifiers
        elements :refNumber, :as => :ref_numbers
      end

      # ======

      class StopDetails
        include SAXMachine

        element :firstTime, :as => :departure_time
        element :date, :as => :departure_date
      end

      class TStop
        include SAXMachine

        elements :stopDetails, :as => :details, :class => StopDetails
        elements :dateQualifier, :as => :qualifiers

        element :locationId, :as => :location_iata
      end
      
      class FlightInformation
        include SAXMachine

        element :operatingCarrier, :as => :operating_carrier
        element :marketingCarrier, :as => :marketing_carrier
        # для locationId и terminal первый элемент это iata и терминал вылета, второй - прилета
        element :flightNumber, :as => :flight_number
        element :dateOfArrival, :as => :arrival_date
        element :timeOfArrival, :as => :arrival_time
        element :dateOfDeparture, :as => :departure_date
        element :timeOfDeparture, :as => :departure_time
        element :equipmentType, :as => :equipment_type

        elements :locationId, :as => :location_ids
        elements :terminal, :as => :terminals
      end

      class FlightProposal
        include SAXMachine
        element :ref
        element :unitQualifier
      end

      class GroupOfFlights
        include SAXMachine

        elements :flightProposal, :as => :flight_proposals, :class => FlightProposal
        elements :flightInformation, :as => :flight_information, :class => FlightInformation
        elements :technicalStop, :as => :technical_stops, :class => TStop
      end

      class FlightIndex
        include SAXMachine

        elements :groupOfFlights, :as => :groups, :class => GroupOfFlights
        # по ходу действительно не надо сюда даже смотреть
        #element :segRef, :as => :segment_ref
      end

      # =====

      class CarrierIATA
        include SAXMachine
        elements :company, :as => :companies
        elements :transportStageQualifier, :as => :qualifiers
        # qualifier == 'V' -> validating_carrier_iata
        # else -> marketing_carrier_iata
      end

      class Fare
        include SAXMachine

        elements :textSubjectQualifier, :as => :qualifiers
        elements :description, :as => :descriptions
      end

      class FlightRecommendation
        include SAXMachine

        element :fareBasis, :as => :fare_basis

        elements :ptc, :as => :ptcs
        elements :fare, :as => :fares, :class => Fare
        elements :amount, :as => :amounts
        elements :cabin, :as => :cabins
        elements :rbd, :as => :booking_classes
        elements :avlStatus, :as => :availabilities
        elements :codeShareDetails, :as => :carrier_iatas, :class => CarrierIATA
        elements :traveller, :as => :travellers
        elements :segmentFlightRef, :as => :segment_flight_refs, :class => SegmentFlightRef
      end

      class XMLResponse
        include SAXMachine

        element :error, :class => ErrorMessage
        elements :recommendation, :as => :recommendations, :class => FlightRecommendation
        elements :flightIndex, :as => :flight_indexes, :class => FlightIndex
      end

      # sax
      def recommendations_sax
        flight_indexes_cache = flight_indexes_sax

        parsed.recommendations.map do |recommendation|

          price_total = recommendation.amounts.first.to_f
          price_tax = recommendation.amounts.second.to_f
          price_fare = price_total - price_tax
          #cabins = recommendation.cabins
          #booking_classes = recommendation.booking_classes
          #availabilities = recommendation.availabilities
          cabins = cabins_sax(recommendation)
          booking_classes = booking_classes_sax(recommendation)
          availabilities = availabilities_sax(recommendation)
          validating_carrier_iata, marketing_carrier_iatas = carrier_iatas_sax(recommendation)
          last_tkt_date = last_tkt_date_sax(recommendation)
          additional_info = additional_info_sax(recommendation)

          #Rails.logger.info "FIC: #{flight_indexes_cache}"
          variants = variants_sax(recommendation, flight_indexes_cache)
          #Rails.logger.info "VARIANTS[1]: #{variants[1]}"

          Recommendation.new(
            source: 'amadeus',
            blank_count: recommendation.travellers.count,
            price_fare: price_fare,
            price_tax: price_tax,
            variants: variants, # not complete
            validating_carrier_iata: validating_carrier_iata,
            suggested_marketing_carrier_iatas: marketing_carrier_iatas,
            additional_info: additional_info,
            cabins: cabins,
            booking_classes: booking_classes,
            availabilities: availabilities,
            last_tkt_date: last_tkt_date
          )
        end
      end

      def variants_sax(recommendation, flight_indexes_cache)
        # fucked up
        variants = []
        #Rails.logger.info "seg count: #{recommendation.segment_flight_refs.count}"

        #flight_indexes_cache.keys.each do |x|
          #flight_indexes_cache[x].keys.each do |y|
            #puts "#{x}, #{y}"
          #end
        #end

        recommendation.segment_flight_refs.map do |segment|
          rnumbers = segment.ref_qualifiers.zip(segment.ref_numbers).select{ |qualifier, number| qualifier == 'S' }.transpose.last.map(&:to_i)

          segments = []

          rnumbers.each_with_index do |number, index|
            #puts "number, index: #{number}, #{index}"
            # segRef is 1-based, so we should add one to index
            #Rails.logger.info "number: #{number}"

            # check if i'm fucking myself up here
            # yeah, i'm sucking a bag of dicks
            ## ok, let me summarize:
            # index is segment
            # number is refNumber
            #puts "fic[number]: #{flight_indexes_cache[number]}"
            segments << flight_indexes_cache[number - 1][index]
          end
          #puts "segments: #{segments}"
          #Rails.logger.info "segments: #{segments}"
          #Rails.logger.info "======"
          variants << Variant.new(segments: segments)# if segments.compact.present?
        end
        variants
      end

      def flight_indexes_sax
        # cache[номер рекомендации][номер сегмента]
        cache = {}

        parsed.flight_indexes.each_with_index do |flight_index, segment_index|
          flight_index.groups.each_with_index do |group, rec_index|
            info = group.flight_information
            proposals = group.flight_proposals
            tstops = group.technical_stops
            estimated_flight_times = []

            #puts "info len: #{info.count}"
            #puts "tstops len: #{tstops.count}: #{tstops}"

            ref, p_eft, dontcare = proposals
            eft_raw = p_eft.ref.to_i
            eft = (eft_raw / 100 * 60 + eft_raw % 100)

            flights = info.map { |inf| parse_flights_sax(inf, tstops) }
            #puts "flights len: #{flights.size}"

            cache[rec_index] ||= {}
            cache[rec_index][segment_index] = Segment.new(
              total_duration: eft,
              flights: flights
            )
          end
          
        end
        cache
      end

      def parse_flights_sax(info, tech_stops)
        Flight.new(
          operating_carrier_iata: info.operating_carrier,
          marketing_carrier_iata: info.marketing_carrier,
          departure_iata: info.location_ids.first,
          departure_term: info.terminals.first,
          arrival_iata: info.location_ids.last,
          arrival_term: info.terminals.last,
          flight_number: info.flight_number,
          arrival_date: info.arrival_date,
          arrival_time: info.arrival_time,
          departure_date: info.departure_date,
          departure_time: info.departure_time,
          equipment_type_iata: info.equipment_type,
          technical_stops: technical_stop_sax(tech_stops)
        )
      end

      def technical_stop_sax(stop)
        return
        #Rails.logger.debug "STOP: #{stop}"
        puts "stop: #{stop}"
        if stop.present?
          dates = {}
          stop.details.zip(stop.qualifiers).each do |d|
            case d.qualifier
            when 'AD'
              dates[:departure_time] = d.details.departure_time
              dates[:departure_date] = d.details.departure_date
            when 'AA'
              dates[:arrival_time] = d.details.departure_time
              dates[:arrival_date] = d.details.departure_date
            end
          end
          #Rails.logger.info "dates: #{dates}"
          TechnicalStop.new(
            departure_date: dates[:departure_date],
            departure_time: dates[:departure_time],
            arrival_date: dates[:arrival_date],
            arrival_time: dates[:arrival_time],
            location_iata: stop.location_iata
          )
        else
          []
        end
      end

      def adult_indexes(recommendation)
        size = recommendation.cabins.size / recommendation.ptcs.size
        ind = recommendation.ptcs.index('ADT')
        from = ind
        to = size * (ind + 1)
        from...to
      end


      # FIXME? объединить методы с похожей логикой
      def cabins_sax(recommendation)
        # нас интересует только первая треть, где ptc = 'ADT'
        cabins = recommendation.cabins
        cabins[adult_indexes(recommendation)]
      end

      def booking_classes_sax(recommendation)
        # нас интересует только первая треть, где ptc = 'ADT'
        booking_classes = recommendation.booking_classes
        booking_classes[adult_indexes(recommendation)]
      end

      def availabilities_sax(recommendation)
        # нас интересует только первая треть, где ptc = 'ADT'
        availabilities = recommendation.availabilities
        availabilities[adult_indexes(recommendation)]
      end

      def additional_info_sax(recommendation)
        fares = recommendation.fares
        descriptions = fares.map(&:descriptions)
        qualifiers = fares.map(&:qualifiers)
        fare_basis = recommendation.fare_basis
        ((descriptions + qualifiers).map { |e| e.join('\n') } ).join('\n\n') + '\n\nfareBasis: ' + fare_basis
      end

      def carrier_iatas_sax(recommendation)
        carrier_iatas = recommendation.carrier_iatas
        marketing_carrier_iatas = carrier_iatas.map(&:companies)
        # validating_carrier_iata
        validating_carrier_iata = nil
        carrier_iatas.map(&:qualifiers).zip(marketing_carrier_iatas).flatten.each_slice(2) do |qualifier, company|
          if qualifier == 'V'
            validating_carrier_iata = company
            break
          end
        end
        [validating_carrier_iata, marketing_carrier_iatas]
      end

      def last_tkt_date_sax(recommendation)
        messages = recommendation.fares
        catch(:date) do
          messages.map(&:descriptions).zip(messages.map(&:qualifiers)).flatten(1).each_slice(2) do |descriptions, qualifier|
            descriptions.each do |description|
              if description =~ /\d+\w{3}\d+/
                throw :date, Date.parse(description)
              end
            end
          end
        end
      end

      def error_message_sax
        parsed.error.message
      rescue NoMethodError
      end

      def error_code_sax
        parsed.error.code
      rescue NoMethodError
      end

      def parsed
        @parsed ||= XMLResponse.parse(doc.to_xml)
      end

      private :parsed,
        :adult_indexes,
        :booking_classes_sax,
        :cabins_sax,
        :additional_info_sax,
        :technical_stop_sax,
        :parse_flights_sax,
        :flight_indexes_sax,
        :variants_sax,
        :carrier_iatas_sax,
        :last_tkt_date_sax
      # /sax
    end

    class FareMasterPricerTravelBoardSearch < Amadeus::Response::Base
      include Monitoring::Benchmarkable
      include FareMasterPricerTravelBoardSearchSax

      def recommendations
        recommendations = benchmark 'search recommendations' do

          return(recommendations_sax) if Conf.amadeus.search_sax

          xpath("//r:recommendation").map do |rec|
            price_total, price_tax =
              rec.xpath("r:recPriceInfo/r:monetaryDetail/r:amount").every.to_f
            price_fare = price_total - price_tax
            blank_count = rec.xpath(".//r:traveller").count
            cabins =
              rec.xpath("r:paxFareProduct[r:paxReference/r:ptc='ADT']/r:fareDetails/r:groupOfFares/r:productInformation/r:cabinProduct/r:cabin").every.to_s
            booking_classes =
              rec.xpath("r:paxFareProduct[r:paxReference/r:ptc='ADT']/r:fareDetails/r:groupOfFares/r:productInformation/r:cabinProduct/r:rbd").every.to_s
            availabilities =
              rec.xpath("r:paxFareProduct[r:paxReference/r:ptc='ADT']/r:fareDetails/r:groupOfFares/r:productInformation/r:cabinProduct/r:avlStatus").every.to_s

            validating_carrier_iata =
              rec.xpath("r:paxFareProduct/r:paxFareDetail/r:codeShareDetails[r:transportStageQualifier='V']/r:company").to_s

            # иногда не все. возможно, только основного перевозчика на маршруте
            marketing_carrier_iatas =
              rec.xpath("r:paxFareProduct/r:paxFareDetail/r:codeShareDetails/r:company").every.to_s
            last_tkt_date =
              rec.xpath("r:paxFareProduct/r:fare/r:pricingMessage[r:freeTextQualification/r:textSubjectQualifier = 'LTD']/r:description").every.to_s.find{|str| str.scan(/\d/).present?}
            last_tkt_date = Date.parse(last_tkt_date) if last_tkt_date

            variants = rec.xpath("r:segmentFlightRef").map {|sf|
              segments = sf.xpath("r:referencingDetail[r:refQualifier='S']").each_with_index.collect { |rd, i|
                flight_indexes[i][ rd.xpath("r:refNumber").to_i - 1 ]
              }
              Variant.new( :segments => segments )
            }

            additional_info =
              rec.xpath('.//r:fare').map {|f|
                f.xpath('.//r:description|.//r:textSubjectQualifier').every.to_s.join("\n")
              }.join("\n\n") +
              "\n\nfareBasis: " +
              rec.xpath('.//r:fareBasis').to_s

            #cabins остаются только у recommendation и не назначаются flight-ам,
            # тк на один и тот же flight продаются билеты разных классов
            Recommendation.new(
              :source => 'amadeus',
              :blank_count => blank_count,
              :price_fare => price_fare,
              :price_tax => price_tax,
              :variants => variants,
              :validating_carrier_iata => validating_carrier_iata,
              :suggested_marketing_carrier_iatas => marketing_carrier_iatas,
              :additional_info => additional_info,
              :cabins => cabins,
              :booking_classes => booking_classes,
              :availabilities => availabilities,
              :last_tkt_date => last_tkt_date
            )
          end
        end
        #puts "REC: #{recommendations}"
        recommendations
      end

      # xpath
      def error_message
        error_message_sax if Conf.amadeus.search_sax

        xpath('//r:errorMessage/r:errorMessageText/r:description').to_s
      end

      def error_code
        error_code_sax if Conf.amadeus.search_sax

        xpath('//r:errorMessage/r:applicationError/r:applicationErrorDetail/r:error').to_s
      end

      private


      def flight_indexes
        @flight_indexes ||= xpath('//r:flightIndex').map do |flight_index|
          flight_index.xpath('r:groupOfFlights').map do |group|
            # 0130 for 1 hour 30 minutes
            estimated_flight_time = group.xpath("r:propFlightGrDetail/r:flightProposal[r:unitQualifier='EFT']/r:ref").to_i
            Segment.new(
              :total_duration => (estimated_flight_time / 100 * 60 + estimated_flight_time % 100),
              :flights => group.xpath("r:flightDetails/r:flightInformation").map { |fi| parse_flight(fi) }
            )
          end
        end
      end

      # fi: flightInformation node
      def parse_flight(fi)
        Flight.new(
          :operating_carrier_iata => fi.xpath("r:companyId/r:operatingCarrier").to_s,
          :marketing_carrier_iata => fi.xpath("r:companyId/r:marketingCarrier").to_s,
          :departure_iata =>         fi.xpath("r:location[1]/r:locationId").to_s,
          :departure_term =>         fi.xpath("r:location[1]/r:terminal").to_s,
          :arrival_iata =>           fi.xpath("r:location[2]/r:locationId").to_s,
          :arrival_term =>           fi.xpath("r:location[2]/r:terminal").to_s,
          :flight_number =>          fi.xpath("r:flightNumber").to_s,
          :arrival_date =>           fi.xpath("r:productDateTime/r:dateOfArrival").to_s,
          :arrival_time =>           fi.xpath("r:productDateTime/r:timeOfArrival").to_s,
          :departure_date =>         fi.xpath("r:productDateTime/r:dateOfDeparture").to_s,
          :departure_time =>         fi.xpath("r:productDateTime/r:timeOfDeparture").to_s,
          :equipment_type_iata =>    fi.xpath("r:productDetail/r:equipmentType").to_s,
          # высчитывается из technical_stops
          # :technical_stop_count =>   fi.xpath("r:productDetail/r:techStopNumber").to_i || 0,
          :technical_stops => fi.xpath('../r:technicalStop').to_a.map{|ts| parse_technical_stop(ts)}
        )
      end

      def parse_technical_stop(ts)
        TechnicalStop.new(
          :departure_time => ts.xpath('r:stopDetails[r:dateQualifier="AD"]/r:firstTime').to_s,
          :departure_date => ts.xpath('r:stopDetails[r:dateQualifier="AD"]/r:date').to_s,
          :arrival_time => ts.xpath('r:stopDetails[r:dateQualifier="AA"]/r:firstTime').to_s,
          :arrival_date => ts.xpath('r:stopDetails[r:dateQualifier="AA"]/r:date').to_s,
          :location_iata => ts.xpath('r:stopDetails/r:locationId').to_s
        )
      end


      public

      # когнитивный ускоритель!
      # пока что не используется, зря?
      # xslt пока что работает только с travel_board_search
      def parse_faster!

        # куда б приткнуть эту строчку?
        # нужна для .to_hash ниже
        ActiveSupport::XmlMini.backend = :Nokogiri

        # FIXME относительный путь?
        xslt = Nokogiri::XSLT(File.read('lib/amadeus/templates/xsl/pricer_flights.xslt'))
        flight_doc = xslt.transform(doc.native_element.document)

        @flight_indexes ||= flight_doc.children.collect do |requested_segment|
          requested_segment.children.collect do |proposed_segment|
            Segment.new(
              :flights => proposed_segment.children.collect { |flight|
                Flight.new(flight.to_hash.values.first)
                #  Hash[*flight.attribute_nodes.map {|node| [node.name, node.value]}.flatten]
                #)
              }
            )
          end
        end
      end
      # /xpath

    end
  end
end

