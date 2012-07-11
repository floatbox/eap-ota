# encoding: utf-8
class SeatMap
  include KeyValueInit
  attr_accessor :segments

  class Segment
    include KeyValueInit
    attr_accessor :aircraft, :departure_iata, :arrival_iata, :departure_date, :rows
  end

  class Row
    include KeyValueInit
    attr_accessor :number, :characteristics, :cabin, :seats

    def exit_row?
      self.characteristics['E'] || false
    end

    def overwing_row?
      self.characteristics['K'] || false
    end

    def lowerdeck_row?
        self.characteristics['L'] || false
    end

    def maindeck_row?
      self.characteristics['M'] || false
    end

    def upperdeck_row?
      self.characteristics['U'] || false
    end
  end

  class Seat
    include KeyValueInit
    attr_accessor :column, :characteristics, :available

    def window?
      self.characteristics['W'] || false
    end

    def aisle?
      self.characteristics['A'] || false
    end

    def center?
      self.characteristics['9'] || false
    end

    def available?
      available
    end
  end
end