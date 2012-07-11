# encoding: utf-8
module Amadeus
  module Response
    class AirRetrieveSeatMap < Amadeus::Response::Base

      def seat_map
        SeatMap.new(:segments => segments)
      end

      def segments
        xpath('//r:segment').map do |xml_segment|
          SeatMap::Segment.new(
            :aircraft => xml_segment.xpath('r:aircraftEquipementDetails/r:meansOfTransport').to_s,
            :departure_iata => xml_segment.xpath('r:flightDateInformation/r:boardpointDetail/r:departureCityCode').to_s,
            :arrival_iata => xml_segment.xpath('r:flightDateInformation/r:offPointDetail/r:arrivalCityCode').to_s,
            :departure_date => xml_segment.xpath('r:flightDateInformation/r:productDetails/r:departureDate').to_s,
            :rows => rows(xml_segment)
          )
        end
      end

      def rows xml_segment
        xml_columns = xml_segment.xpath('r:cabin/r:cabinDetails')
        xml_segment.xpath('r:row/r:rowDetails').map do |xml_row|
          row = SeatMap::Row.new(
            :number => xml_row.xpath('r:seatRowNumber').to_s,
            :characteristics => {},
            :seats => seats(xml_row, xml_columns)
          )
          #ищем cabin, в диапазон рядов которой попадает текущий ряд
          row.cabin = xml_segment.xpath("r:cabin/r:cabinDetails[r:cabinRangeOfRowsDetail/r:seatRowNumber[1]<='#{row.number}']
          [r:cabinRangeOfRowsDetail/r:seatRowNumber[2]>='#{row.number}']/r:cabinClassDesignation/r:cabinClassDesignator").to_s

          #сохраняем разнообразные закодированные характеристики ряда, почти полный их список в доках амадеуса
          xml_row.xpath('r:rowCharacteristicDetails/r:rowCharacteristic').each do |characteristic|
            row.characteristics[characteristic.to_s] = true
          end
          row
        end
      end

      def seats xml_row, xml_columns
        xml_row.xpath('r:seatOccupationDetails').map do |xml_seat|
          seat = SeatMap::Seat.new(
            :column => xml_seat.xpath('r:seatColumn').first.to_s,
            :available => xml_seat.xpath('r:seatOccupation').to_s == 'F',
            :characteristics => {}
          )
          #сохраняем разнообразные закодированные характеристики места, почти полный их список в доках амадеуса
          #TODO: выяснить, что за характеристика 'CH'. или это 'C' и 'H'?
          xml_seat.xpath('r:seatCharacteristic').each do |characteristic|
            seat.characteristics[characteristic.to_s] = true
          end
          #смотрим по букве колонны и сохраняем характеристики колонны(окошко, проход, пр) в характеристики места
          xml_columns.each do |xml_column|
            seat.characteristics[xml_column.xpath("r:cabinColumnDetails[r:seatColumn='#{seat.column}']/r:columnCharacteristic").to_s] = true
          end
          seat
        end
      end

    end
  end
end

