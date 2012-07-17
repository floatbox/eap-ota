# encoding: utf-8
module Amadeus
  module Response
    class AirRetrieveSeatMap < Amadeus::Response::Base

      def seat_map
        SeatMap.new(:segments => segments)
      end

      def segments
        xpath('//r:segment').map do |xml_segment|
          segment = SeatMap::Segment.new(
            :aircraft => xml_segment.xpath('r:aircraftEquipementDetails/r:meansOfTransport').to_s,
            :departure_iata => xml_segment.xpath('r:flightDateInformation/r:boardpointDetail/r:departureCityCode').to_s,
            :arrival_iata => xml_segment.xpath('r:flightDateInformation/r:offPointDetail/r:arrivalCityCode').to_s,
            :departure_date => xml_segment.xpath('r:flightDateInformation/r:productDetails/r:departureDate').to_s
          )
          segment.columns = columns(xml_segment, segment)
          segment.rows = rows(xml_segment, segment)
          segment
        end
      end

      def rows xml_segment, segment
        rows = {}
        xml_segment.xpath('r:row/r:rowDetails').each do |xml_row|
          row = SeatMap::Row.new(
            :segment => segment,
            :number => xml_row.xpath('r:seatRowNumber').to_s,
            :characteristics => {},
            :seats => seats(xml_row, segment)
          )
          #ищем cabin, в диапазон рядов которой попадает текущий ряд
          row.cabin = xml_segment.xpath("r:cabin/r:cabinDetails[r:cabinRangeOfRowsDetail/r:seatRowNumber[1]<='#{row.number}']
          [r:cabinRangeOfRowsDetail/r:seatRowNumber[2]>='#{row.number}']/r:cabinClassDesignation/r:cabinClassDesignator").to_s

          #сохраняем разнообразные закодированные характеристики ряда, почти полный их список в доках амадеуса
          xml_row.xpath('r:rowCharacteristicDetails/r:rowCharacteristic').each do |characteristic|
            row.characteristics[characteristic.to_s] = true
          end
          rows[row.number] = row
        end
        rows
      end

      def columns xml_segment, segment
        columns = {}
        xml_segment.xpath('r:cabin/r:cabinDetails/r:cabinColumnDetails').each do |xml_column|
          column = SeatMap::Column.new(
            :segment => segment,
            :name => xml_column.xpath("r:seatColumn").to_s,
            :characteristics => {})
          #сохраняем разнообразные закодированные характеристики колонны, почти полный их список в доках амадеуса
          xml_column.xpath('r:columnCharacteristic').each do |characteristic|
            column.characteristics[characteristic.to_s] = true
          end
          columns[column.name] = column
        end
        columns
      end

      def seats xml_row, segment
        seats = {}
        row_number = xml_row.xpath("r:seatRowNumber").to_s
        xml_row.xpath('r:seatOccupationDetails').each do |xml_seat|
          seat = SeatMap::Seat.new(
            :segment => segment,
            :column_name => xml_seat.xpath('r:seatColumn').first.to_s,
            :row => row_number,
            :available => xml_seat.xpath('r:seatOccupation').to_s == 'F',
            :characteristics => {})
          #TODO: выяснить, что за характеристика 'CH'. или это 'C' и 'H'?
          #сохраняем разнообразные закодированные характеристики места, почти полный их список в доках амадеуса
          xml_seat.xpath('r:seatCharacteristic').each do |characteristic|
            seat.characteristics[characteristic.to_s] = true
          end
          seats[seat.row+seat.column_name] = seat
        end
        seats
      end

    end
  end
end

