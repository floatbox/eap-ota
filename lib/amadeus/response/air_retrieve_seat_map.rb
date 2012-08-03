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
          segment.cabins = cabins(xml_segment, segment)
          segment
        end
      end

      def cabins  xml_segment, segment
        xml_segment.xpath('r:cabin').map do |xml_cabin|
          row_range = xml_cabin.xpath("r:cabinDetails/r:cabinRangeOfRowsDetail/r:seatRowNumber")[0].to_i..xml_cabin.xpath("r:cabinDetails/r:cabinRangeOfRowsDetail/r:seatRowNumber")[1].to_i
          overwing_row_range = xml_cabin.xpath("r:cabinDetails/r:overwingRowRange/r:seatRowNumber")[0].to_i..xml_cabin.xpath("r:cabinDetails/r:overwingRowRange/r:seatRowNumber")[1].to_i

          cabin = SeatMap::Cabin.new(
            :segment => segment,
            :class => xml_cabin.xpath('r:cabinDetails/r:cabinClassDesignation/r:cabinClassDesignator').to_s,
            :occupation_default => xml_cabin.xpath('r:cabinDetails/r:seatOccupationDefault').to_s
          )
          cabin.columns = columns(xml_cabin, cabin)
          cabin.rows = rows(xml_segment, cabin, row_range, overwing_row_range)
          cabin
        end
      end

      def rows xml_segment, cabin, row_range, overwing_row_range
        rows = {}
        xml_segment.xpath('r:row/r:rowDetails').select do |xml_row|
          row_range === xml_row.xpath('r:seatRowNumber').to_i
        end.each do |xml_row|
          row = SeatMap::Row.new(
            :cabin => cabin,
            :number => xml_row.xpath('r:seatRowNumber').to_s,
            :characteristics => {},
            :overwing => overwing_row_range === xml_row.xpath('r:seatRowNumber').to_i
          )
          #сохраняем разнообразные закодированные характеристики ряда, почти полный их список в доках амадеуса
          xml_row.xpath('r:rowCharacteristicsDetails/r:rowCharacteristic').each do |characteristic|
            row.characteristics[characteristic.to_s] = true
          end
          row.seats = seats(xml_row, cabin, row)

          rows[row.number] = row
        end
        rows
      end

      def columns xml_cabin, cabin
        columns = {}
        xml_cabin.xpath('r:cabinDetails/r:cabinColumnDetails').each do |xml_column|
          column = SeatMap::Column.new(
            :cabin => cabin,
            :name => xml_column.xpath("r:seatColumn").to_s,
            :characteristics => {})
          # сохраняем разнообразные закодированные характеристики колонны, почти полный их список в доках амадеуса
          xml_column.xpath('r:columnCharacteristic').each do |characteristic|
            column.characteristics[characteristic.to_s] = true
          end
          columns[column.name] = column
        end
        columns.values.each_cons(2) do |left, right|
          # не хотим кресел с проходами с обеих сторон
          next if left.aisle_to_the_left
          if left.aisle? && right.aisle?
            left.aisle_to_the_right = true
            right.aisle_to_the_left = true
          end
        end
        columns
      end

      def seats xml_row, cabin, row
        seats = {}
        row_number = xml_row.xpath("r:seatRowNumber").to_s
        cabin.columns.values.each do |column|
          xml_seat = xml_row.xpath("r:seatOccupationDetails[r:seatColumn='#{column.name}']").first
          if xml_seat
            seat = SeatMap::Seat.new(
              :cabin => cabin,
              :column => column,
              :row => row,
              :available => xml_seat.xpath('r:seatOccupation').to_s,
              :characteristics => {})
            #TODO: выяснить, что за характеристика 'CH'. или это 'C' и 'H'?
            #сохраняем разнообразные закодированные характеристики места, почти полный их список в доках амадеуса
            xml_seat.xpath('r:seatCharacteristic').each do |characteristic|
              seat.characteristics[characteristic.to_s] = true
            end
          else
            seat = SeatMap::Seat.new(
              :cabin => cabin,
              :column => column,
              :row => row,
              :available => cabin.occupation_default,
              :characteristics => {'0' => true})
          end
          seats[seat.name] = seat
        end
        seats
      end

      def error_message
        xpath('//r:errorDetails/r:errorInformation/r:errorNumber').to_s.try(:strip)
      end

    end
  end
end

