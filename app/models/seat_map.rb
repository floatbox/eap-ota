# encoding: utf-8
class SeatMap
  include KeyValueInit
  attr_accessor :segments

  class Segment
    include KeyValueInit
    attr_accessor :aircraft, :departure_iata, :arrival_iata, :departure_date, :rows, :columns

    def seats
      rows.each(&:seats)
    end

    def [] seat_id
      row = rows[seat_id[0]]
      row.seats[seat_id]
    end

  end

  class Row
    include KeyValueInit
    attr_accessor :number, :characteristics, :cabin, :seats, :segment

    def exit_row?
      characteristics['E']
    end

    def overwing_row?
      characteristics['K']
    end

    def lowerdeck_row?
      characteristics['L']
    end

    def maindeck_row?
      characteristics['M']
    end

    def upperdeck_row?
      characteristics['U']
    end
  end

  class Column
    include KeyValueInit
    attr_accessor :name, :characteristics, :segment

    def window?
      characteristics['W']
    end

    def aisle?
      characteristics['A']
    end

    def center?
      characteristics['9']
    end

    def seats
      segment.seats.find_all{|seat| seat.column == name}
    end
  end

  class Seat
    include KeyValueInit
    attr_accessor :segment, :column_name, :row, :characteristics, :available
    delegate :window?, :aisle?, :center?, :to => :column

    def column
      @column ||= segment.columns[column_name]
    end

    def available?
      available
    end
  end
end