module Amadeus::Response::FareMasterPricerTravelBoardSearchSax
  class XMLResponse
    include CompactSAXMachine

    element :error do
      element :description, :as => :message
      element :error, :as => :code
    end
    elements :recommendation, :as => :recommendations do
      elements :ptc, :as => :ptcs
      elements :paxFareProduct, :as => :pax_fare_products do
        element :ptc
        elements :fareDetails, :as => :fare_details do
          element :segRef, :as => :seg_ref
          elements :productInformation, :as => :product_information do
            element :cabin
            element :rbd, :as => :booking_class
            element :avlStatus, :as => :availability
            element :passengerType, :as => :passenger_type
          end
        end
        elements :codeShareDetails, :as => :carrier_iatas do
          elements :company, :as => :companies
          elements :transportStageQualifier, :as => :qualifiers
        end
        elements :traveller, :as => :travellers
        elements :fare, :as => :fares do
          elements :textSubjectQualifier, :as => :qualifiers
          elements :description, :as => :descriptions
        end
      end
      elements :amount, :as => :amounts
      elements :segmentFlightRef, :as => :segment_flight_refs do
        elements :refQualifier, :as => :ref_qualifiers
        elements :refNumber, :as => :ref_numbers
      end
    end
    elements :flightIndex, :as => :flight_indexes do
      elements :groupOfFlights, :as => :groups do
        elements :flightProposal, :as => :flight_proposals do
          element :ref
          element :unitQualifier
        end
        elements :flightDetails, :as => :flight_details do
          element :flightInformation, :as => :flight_information do
            element :operatingCarrier, :as => :operating_carrier
            element :marketingCarrier, :as => :marketing_carrier
            element :flightNumber, :as => :flight_number
            element :dateOfArrival, :as => :arrival_date
            element :timeOfArrival, :as => :arrival_time
            element :dateOfDeparture, :as => :departure_date
            element :timeOfDeparture, :as => :departure_time
            element :equipmentType, :as => :equipment_type
            elements :location, :as => :endpoints_info do
              element :locationId, :as => :location_id
              element :terminal, :as => :terminal
            end
          end
          elements :technicalStop, :as => :technical_stops do
            elements :stopDetails, :as => :details do
              element :locationId, :as => :location_iata
              element :firstTime, :as => :departure_time
              element :date, :as => :departure_date
              element :dateQualifier, :as => :qualifier
            end
          end
        end
      end
    end
  end

  # sax
  def recommendations_sax
    flight_indexes_cache = flight_indexes_sax

    parsed.recommendations.map do |recommendation|

      blank_count = recommendation.pax_fare_products.flat_map(&:travellers).size
      price_total = recommendation.amounts.first.to_f
      price_tax = recommendation.amounts.last.to_f
      price_fare = price_total - price_tax

      # booking_classes/availabilities/cabins
      pax_fare_product = recommendation.pax_fare_products.find { |pfp| pfp.ptc == 'ADT' }
      # FIXME нужна ли тут вторая проверка на ADT? passengerType может отличаться от ptc?
      product_informations = pax_fare_product.fare_details.flat_map(&:product_information).select { |inf| inf.passenger_type == 'ADT' }
      cabins = product_informations.map(&:cabin)
      booking_classes = product_informations.map(&:booking_class)
      availabilities = product_informations.map(&:availability)

      validating_carrier_iata, marketing_carrier_iatas = carrier_iatas_sax(pax_fare_product)
      last_tkt_date = last_tkt_date_sax(pax_fare_product)
      additional_info = additional_info_sax(pax_fare_product)

      variants = variants_sax(recommendation, flight_indexes_cache)

      Recommendation.new(
        source: 'amadeus',
        blank_count: blank_count,
        price_fare: price_fare,
        price_tax: price_tax,
        variants: variants,
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
    variants = []

    recommendation.segment_flight_refs.map do |segment|
      rnumbers = segment.ref_qualifiers.zip(segment.ref_numbers).select{ |qualifier, number| qualifier == 'S' }.transpose.last.map(&:to_i)

      segments = []

      rnumbers.each_with_index do |number, index|
        segments << flight_indexes_cache[number - 1][index]
      end
      variants << Variant.new(segments: segments)# if segments.compact.present?
    end
    variants
  end

  def flight_indexes_sax
    # cache[номер рекомендации][номер сегмента]
    result = {}

    parsed.flight_indexes.each_with_index do |flight_index, segment_index|
      flight_index.groups.each_with_index do |group, rec_index|

        proposals = group.flight_proposals

        ref, p_eft, dontcare = proposals
        eft_raw = p_eft.ref.to_i
        eft = (eft_raw / 100 * 60 + eft_raw % 100)

        flights = []

        group.flight_details.each do |details|
          info = details.flight_information
          technical_stops = details.technical_stops

          tstops = technical_stops.map { |ts| technical_stop_sax(ts) }
          flights << parse_flights_sax(info, tstops)
        end

        result[rec_index] ||= {}
        result[rec_index][segment_index] = Segment.new(
          total_duration: eft,
          flights: flights
        )
      end
    end
    result
  end

  def parse_flights_sax(info, tech_stops)
    Flight.new(
      operating_carrier_iata: info.operating_carrier,
      marketing_carrier_iata: info.marketing_carrier,
      # для locationId и terminal первый элемент это iata и терминал вылета, второй - прилета
      departure_iata: info.endpoints_info.first.location_id,
      departure_term: info.endpoints_info.first.terminal,
      arrival_iata: info.endpoints_info.second.location_id,
      arrival_term: info.endpoints_info.second.terminal,
      flight_number: info.flight_number,
      arrival_date: info.arrival_date,
      arrival_time: info.arrival_time,
      departure_date: info.departure_date,
      departure_time: info.departure_time,
      equipment_type_iata: info.equipment_type,
      technical_stops: tech_stops
    )
  end

  def technical_stop_sax(stop)
    details = stop.details

    info = {}

    details.each do |d|
      case d.qualifier
      when 'AD'
        info[:departure_time] = d.departure_time
        info[:departure_date] = d.departure_date
      when 'AA'
        info[:arrival_time] = d.departure_time
        info[:arrival_date] = d.departure_date
        info[:location_iata] = d.location_iata
      end
    end
    TechnicalStop.new(
      departure_date: info[:departure_date],
      departure_time: info[:departure_time],
      arrival_date: info[:arrival_date],
      arrival_time: info[:arrival_time],
      location_iata: info[:location_iata]
    )
  end

  def additional_info_sax(pax_fare_product)
    fares = pax_fare_product.fares
    descriptions = fares.collect(&:descriptions)
    qualifiers = fares.collect(&:qualifiers)
    starter = descriptions + qualifiers
    # здесь явное отличие additional_info от старого парсера - нигде не используется, не стал заморачиваться с fare_basis
    starter.map{ |e| e.join('\n')}.join('\n\n')
  end

  def carrier_iatas_sax(pax_fare_product)
    # qualifier == 'V' -> validating_carrier_iata
    # else -> marketing_carrier_iata
    carrier_iatas = pax_fare_product.carrier_iatas
    marketing_carrier_iatas = carrier_iatas.flat_map(&:companies)
    qualifiers = carrier_iatas.flat_map(&:qualifiers)

    validating_carrier_iata = nil
    qualifiers.zip(marketing_carrier_iatas) do |qualifier, company|
      if qualifier == 'V'
        validating_carrier_iata = company
        break
      end
    end
    [validating_carrier_iata, marketing_carrier_iatas]
  end

  def last_tkt_date_sax(pax_fare_product)
    messages = pax_fare_product.fares
    messages.map(&:descriptions).zip(messages.map(&:qualifiers)) do |descriptions, qualifier|
      descriptions.each do |description|
        if description =~ /\d+\w{3}\d+/
          return Date.parse(description)
        end
      end
    end

    return
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
    xml = benchmark 'to_xml' do doc.to_xml end
    @parsed ||= XMLResponse.parse(xml)
  end

  private :parsed,
    :additional_info_sax,
    :technical_stop_sax,
    :parse_flights_sax,
    :flight_indexes_sax,
    :variants_sax,
    :carrier_iatas_sax,
    :last_tkt_date_sax

end
