module Amadeus::Response::FareMasterPricerTravelBoardSearchSax
  # FIXME не доверять выбору element/elements ниже
  # некоторые "дочерние" элементы - на самом деле глубоко по иерархии
  # TODO документировать, какие именно?
  class XMLResponse
    include CompactSAXMachine

    element :error do
      element :description
      element :error
    end
    elements :recommendation do
      elements :paxFareProduct do
        element :ptc
        def adt?; ptc == 'ADT' end
        elements :fareDetails do
          element :segRef
          elements :productInformation do
            element :cabin
            element :rbd
            element :avlStatus
            element :passengerType
            def adt?; passengerType == 'ADT' end
          end
        end
        elements :codeShareDetails do
          element :company
          element :transportStageQualifier
          def v?; transportStageQualifier == 'V' end
        end
        elements :traveller
        elements :fare do
          element :textSubjectQualifier
          elements :description
          def ltd?; textSubjectQualifier == 'LTD' end
        end
      end
      elements :amount
      elements :segmentFlightRef do
        elements :referencingDetail do
          element :refQualifier
          element :refNumber
          def s?; refQualifier == 'S' end
        end
      end
    end
    elements :flightIndex do
      elements :groupOfFlights do
        elements :flightProposal do
          element :ref
          element :unitQualifier
          def eft?; unitQualifier == 'EFT' end
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
              def arrival?;   dateQualifier == 'AA' end
              def departure?; dateQualifier == 'AD' end
            end
          end
        end
      end
    end
  end

  private

  def recommendations_sax
    flight_indexes_cache = flight_indexes_sax

    parsed.recommendation.map do |recommendation|

      blank_count = recommendation.paxFareProduct.flat_map(&:traveller).size
      price_total = recommendation.amount.first.to_f
      price_tax = recommendation.amount.second.to_f
      price_fare = price_total - price_tax

      # booking_classes/availabilities/cabins
      pax_fare_product = recommendation.paxFareProduct.find(&:adt?)
      # FIXME нужна ли тут вторая проверка на ADT? passengerType может отличаться от ptc?
      product_informations = pax_fare_product.fareDetails.flat_map(&:productInformation).select(&:adt?)
      cabins = product_informations.map(&:cabin)
      booking_classes = product_informations.map(&:rbd)
      availabilities = product_informations.map(&:avlStatus)

      validating_carrier_iata = pax_fare_product.codeShareDetails.find(&:v?).company
      marketing_carrier_iatas = pax_fare_product.codeShareDetails.map(&:company)

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
    recommendation.segmentFlightRef.map do |segment|
      rnumbers = segment.referencingDetail.select(&:s?).map(&:refNumber)

      segments = flight_indexes_cache.zip(rnumbers).map do |possible_segments, rnumber|
        possible_segments[rnumber.to_i - 1]
      end

      Variant.new(segments: segments)
    end
  end

  def flight_indexes_sax
    # cache[номер сегмента, 0 based][номер варианта перелетов по сегменту, 0 based]
    parsed.flightIndex.map do |flight_index|
      flight_index.groupOfFlights.map do |group|

        eft_raw = group.flightProposal.find(&:eft?).ref.to_i
        eft = (eft_raw / 100 * 60 + eft_raw % 100)

        flights = group.flightDetails.map { |details| parse_flights_sax(details) }

        Segment.new(
          total_duration: eft,
          flights: flights
        )
      end
    end
  end

  def parse_flights_sax(details)
    info = details.flightInformation
    technical_stops = details.technicalStop.map { |ts| technical_stop_sax(ts) }
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
      technical_stops: technical_stops
    )
  end

  def technical_stop_sax(stop)
    arrival   = stop.stopDetails.find(&:arrival?)
    departure = stop.stopDetails.find(&:departure?)
    TechnicalStop.new(
      departure_date: departure.date,
      departure_time: departure.firstTime,
      arrival_date: arrival.date,
      arrival_time: arrival.firstTime,
      location_iata: arrival.locationId
    )
  end

  # debug information
  def additional_info_sax(pax_fare_product)
    return ""
    pax_fare_product.fare.map {|pricing_message|
      ([pricing_message.textSubjectQualifier] + pricing_message.description)
    }.join("\n")
  end

  def last_tkt_date_sax(pax_fare_product)
    ltd_message = pax_fare_product.fare.find(&:ltd?)
    date_str = ltd_message.description.grep(/^\d+\w{3}\d+$/).first or
      raise "no last ticket date found in pricing message #{ltd_message.description.inspect}"
    Date.parse(date_str)
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
end
