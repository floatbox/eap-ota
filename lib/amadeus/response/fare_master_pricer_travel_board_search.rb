module Amadeus
  module Response
    class FareMasterPricerTravelBoardSearch < Amadeus::Response::Base

      def recommendations
        xpath("//r:recommendation").map do |rec|
          price_total, price_tax =
            rec.xpath("r:recPriceInfo/r:monetaryDetail/r:amount").every.to_i
          price_fare = price_total - price_tax
          cabins =
            rec.xpath("r:paxFareProduct[r:paxReference/r:ptc='ADT']/r:fareDetails/r:groupOfFares/r:productInformation/r:cabinProduct/r:cabin").every.to_s
          booking_classes =
            rec.xpath("r:paxFareProduct[r:paxReference/r:ptc='ADT']/r:fareDetails/r:groupOfFares/r:productInformation/r:cabinProduct/r:rbd").every.to_s
=begin
          booking_classes_child = rec.xpath("r:paxFareProduct[r:paxReference/r:ptc='CH']/r:fareDetails/r:groupOfFares/r:productInformation/r:cabinProduct/r:rbd").every.to_s
          fare_basis_child = rec.xpath("r:paxFareProduct[r:paxReference/r:ptc='CH']/r:fareDetails/r:groupOfFares/r:productInformation/r:fareProductDetail/r:fareBasis").every.to_s
          booking_classes_infant = rec.xpath("r:paxFareProduct[r:paxReference/r:ptc='INF']/r:fareDetails/r:groupOfFares/r:productInformation/r:cabinProduct/r:rbd").every.to_s
          fare_basis_infant = rec.xpath("r:paxFareProduct[r:paxReference/r:ptc='INF']/r:fareDetails/r:groupOfFares/r:productInformation/r:fareProductDetail/r:fareBasis").every.to_s


          fare_details = {}
          fare_details[:fare_basis] = rec.xpath("r:paxFareProduct[r:paxReference/r:ptc='ADT']/r:fareDetails/r:groupOfFares/r:productInformation/r:fareProductDetail/r:fareBasis").every.to_s
          fare_details[:booking_classes_child] = booking_classes_child if booking_classes_child != booking_classes
          fare_details[:fare_basis_child] = fare_basis_child if fare_basis_child != fare_details[:fare_basis]
          fare_details[:booking_classes_infant] = booking_classes_infant if booking_classes_infant != booking_classes
          fare_details[:fare_basis_infant] = fare_basis_infant if fare_basis_infant != fare_details[:fare_basis]
          debugger if fare_details[:booking_classes_infant] || fare_details[:booking_classes_child]
=end

          validating_carrier_iata =
            rec.xpath("r:paxFareProduct/r:paxFareDetail/r:codeShareDetails[r:transportStageQualifier='V']/r:company").to_s

          # иногда не все. возможно, только основного перевозчика на маршруте
          marketing_carrier_iatas =
            rec.xpath("r:paxFareProduct/r:paxFareDetail/r:codeShareDetails/r:company").every.to_s

          variants = rec.xpath("r:segmentFlightRef").map {|sf|
            segments = sf.xpath("r:referencingDetail").each_with_index.collect { |rd, i|
              # TODO проверить что:
              # rd["refQualifier"] == "S"
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
            :price_fare => price_fare,
            :price_tax => price_tax,
            :variants => variants,
            :validating_carrier_iata => validating_carrier_iata,
            :marketing_carrier_iatas => marketing_carrier_iatas,
            :additional_info => additional_info,
            :cabins => cabins,
            :booking_classes => booking_classes
          )
        end
      end

      private

      def flight_indexes
        @flight_indexes ||= xpath('//r:flightIndex').map do |flight_index|
          flight_index.xpath('r:groupOfFlights').map do |group|
            Segment.new(
              :eft => group.xpath("r:propFlightGrDetail/r:flightProposal[r:unitQualifier='EFT']/r:ref").to_s,
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

    end
  end
end
