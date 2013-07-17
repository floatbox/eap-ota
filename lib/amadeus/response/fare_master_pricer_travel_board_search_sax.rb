module Amadeus::Response::FareMasterPricerTravelBoardSearchSax
  class XMLResponse
    include CompactSAXMachine

    element :error do
      element :description
      element :error
    end
    elements :recommendation do
      elements :paxFareProduct do
        element :ptc
        elements :fareDetails do
          element :segRef
          elements :productInformation do
            element :cabin
            element :rbd
            element :avlStatus
            element :passengerType
          end
        end
        elements :codeShareDetails do
          # почему это массивы?
          elements :company
          elements :transportStageQualifier
        end
        elements :traveller
        elements :fare do
          elements :textSubjectQualifier
          elements :description
        end
      end
      elements :amount
      elements :segmentFlightRef do
        elements :refQualifier
        elements :refNumber
      end
    end
    elements :flightIndex do
      elements :groupOfFlights do
        elements :flightProposal do
          element :ref
          element :unitQualifier
        end
        elements :flightDetails do
          element :flightInformation do
            element :operatingCarrier
            element :marketingCarrier
            element :flightNumber
            element :dateOfArrival
            element :timeOfArrival
            element :dateOfDeparture
            element :timeOfDeparture
            element :equipmentType
            elements :location do
              element :locationId
              element :terminal
            end
          end
          elements :technicalStop do
            elements :stopDetails do
              element :locationId
              element :firstTime
              element :date
              element :dateQualifier
            end
          end
        end
      end
    end
  end

  # sax
  def recommendations_sax
    flight_indexes_cache = flight_indexes_sax

    parsed.recommendation.map do |recommendation|

      blank_count = recommendation.paxFareProduct.flat_map(&:traveller).size
      price_total = recommendation.amount.first.to_f
      price_tax = recommendation.amount.last.to_f
      price_fare = price_total - price_tax

      # booking_classes/availabilities/cabins
      pax_fare_product = recommendation.paxFareProduct.find { |pfp| pfp.ptc == 'ADT' }
      # FIXME нужна ли тут вторая проверка на ADT? passengerType может отличаться от ptc?
      product_informations = pax_fare_product.fareDetails.flat_map(&:productInformation).select { |inf| inf.passengerType == 'ADT' }
      cabins = product_informations.map(&:cabin)
      booking_classes = product_informations.map(&:rbd)
      availabilities = product_informations.map(&:avlStatus)

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

    recommendation.segmentFlightRef.map do |segment|
      rnumbers = segment.refQualifier.zip(segment.refNumber).select{ |qualifier, number| qualifier == 'S' }.transpose.last.map(&:to_i)

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

    parsed.flightIndex.each_with_index do |flight_index, segment_index|
      flight_index.groupOfFlights.each_with_index do |group, rec_index|

        proposals = group.flightProposal

        ref, p_eft, dontcare = proposals
        eft_raw = p_eft.ref.to_i
        eft = (eft_raw / 100 * 60 + eft_raw % 100)

        flights = []

        group.flightDetails.each do |details|
          info = details.flightInformation
          technical_stops = details.technicalStop

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
      operating_carrier_iata: info.operatingCarrier,
      marketing_carrier_iata: info.marketingCarrier,
      # для locationId и terminal первый элемент это iata и терминал вылета, второй - прилета
      departure_iata: info.location.first.locationId,
      departure_term: info.location.first.terminal,
      arrival_iata: info.location.second.locationId,
      arrival_term: info.location.second.terminal,
      flight_number: info.flightNumber,
      arrival_date: info.dateOfArrival,
      arrival_time: info.timeOfArrival,
      departure_date: info.dateOfDeparture,
      departure_time: info.timeOfDeparture,
      equipment_type_iata: info.equipmentType,
      technical_stops: tech_stops
    )
  end

  def technical_stop_sax(stop)
    details = stop.stopDetails

    info = {}

    details.each do |d|
      case d.dateQualifier
      when 'AD'
        info[:departure_time] = d.firstTime
        info[:departure_date] = d.date
      when 'AA'
        info[:arrival_time] = d.firstTime
        info[:arrival_date] = d.date
        info[:location_iata] = d.locationId
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
    fares = pax_fare_product.fare
    descriptions = fares.collect(&:description)
    qualifiers = fares.collect(&:textSubjectQualifier)
    starter = descriptions + qualifiers
    # здесь явное отличие additional_info от старого парсера - нигде не используется, не стал заморачиваться с fare_basis
    starter.map{ |e| e.join('\n')}.join('\n\n')
  end

  def carrier_iatas_sax(pax_fare_product)
    # qualifier == 'V' -> validating_carrier_iata
    # else -> marketing_carrier_iata
    carrier_iatas = pax_fare_product.codeShareDetails
    marketing_carrier_iatas = carrier_iatas.flat_map(&:company)
    qualifiers = carrier_iatas.flat_map(&:transportStageQualifier)

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
    messages = pax_fare_product.fare
    messages.map(&:description).zip(messages.map(&:textSubjectQualifier)) do |descriptions, qualifier|
      descriptions.each do |description|
        if description =~ /\d+\w{3}\d+/
          return Date.parse(description)
        end
      end
    end

    return
  end

  def error_message_sax
    parsed.error.description
  rescue NoMethodError
  end

  def error_code_sax
    parsed.error.error
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
