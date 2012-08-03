# encoding: utf-8
class SeatMap
  include KeyValueInit
  attr_accessor :segments

  class Segment
    include KeyValueInit
    attr_accessor :aircraft, :departure_iata, :arrival_iata, :departure_date, :rows, :columns, :cabins_count

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


  SEAT_PROPS= Hash[ <<-"END".lines.map {|l| l.strip.split(/\s+/, 2) } ]
    1       Restricted seat - General
    10      Seat designated for RBD "A"
    11      Seat designated for RBD "B"
    12      Seat designated for RBD "C"
    13      Seat designated for RBD "D"
    14      Seat designated for RBD "F"
    15      Seat designated for RBD "H"
    16      Seat designated for RBD "J"
    17      Seat designated for RBD "K"
    18      Seat designated for RBD "L"
    19      Seat designated for RBD "M"
    1A      Seat not allowed for infant
    1B      Seat not allowed for medical
    1C      Seat not allowed for unaccompanied minor
    1D      Restricted recline seat
    1M      Seat with movie view
    1W      Window seat without window
    2       Leg rest available
    20      Seat designated for RBD "P"
    21      Seat designated for RBD "Q"
    22      Seat designated for RBD "R"
    23      Seat designated for RBD "S"
    24      Seat designated for RBD "T"
    25      Seat designated for RBD "V"
    26      Seat designated for RBD "W"
    27      Seat designated for RBD "Y"
    3       Individual video screen - Choice of movies
    3A      Individual video screen - No choice of movie
    3B      Individual video screen-Choice of movies, games, information, etc
    4       Not a window seat
    5       Not an aisle seat
    6       Near galley seat
    6A      In front of galley seat
    6B      Behind galley seat
    7       Near toilet seat
    700     Individual video screen - services unspecified
    701     No seat --access to handicapped lavatory
    7A      In front of toilet seat
    7B      Behind toilet seat
    8       No seat at this location
    9       Center seat (not window, not aisle)
    A       Aisle seat
    AA      All available aisle seats
    AB      Seat adjacent to bar
    AC      Seat adjacent to - closet
    AG      Seat adjacent to galley
    AJ      Adjacent aisle seats
    AL      Seat adjacent to lavatory
    AM      Individual movie screen - No choice of movie selection
    AR      No seat - airphone
    AS      Individual airphone
    AT      Seat adjacent to table
    AU      Seat adjacent to stairs to upper deck
    AV      Only available seats
    AW      All available window seats
    B       Seat with bassinet facility
    BA      No seat - bar
    BK      Blocked Seat for preferred passenger in adjacent seat
    C       Crew seat
    CC      Center section seat(s)
    CL      No seat - closet
    CS      Conditional seat-contact airline
    D       No seat - exit door
    DE      Deportee
    E       Exit row seat
    EA      Not on exit seat
    EC      Electronic connection for lap top or FAX machine
    EX      No seat - emergency Exit
    F       Added seat
    FC      Front of cabin class/compartment
    G       Seat at forward end of cabin
    GF      General facility
    GN      No seat - galley
    GR      Group seat - offered to travellers belonging to a group
    H       Seat with facilities for handicapped/incapacitated passenger
    I       Seat suitable for adult with an infant
    IA      Inside aisle seats
    IE      Seat not suitable for child
    J       Rear facing seat
    K       Bulkhead seat
    KA      Bulkhead seat with movie screen
    KN      Bulkhead, no seat
    L       Leg space seat
    LA      No seat - lavatory
    LG      No seat - luggage storage
    LH      Restricted seat - offered on long-haul segments
    LS      Left side of aircraft
    M       Seat without a movie view
    MA      Medically OK to travel
    N       No smoking seat
    O       Preferential seat
    OW      Overwing seat(s)
    PC      Pet cabin
    Q       Seat in a quiet zone
    RS      Right side of aircraft
    S       Smoking seat
    SO      No seat - storage space
    ST      No seat - stairs to upper deck
    T       Rear/Tail section of aircraft
    TA      No seat - table
    U       Seat suitable for unaccompanied minors
    UP      Upper deck
    V       Seat to be left vacant or offered last
    W       Window seat
    WA      Window and aisle together
    X       No facility seat (indifferent seat)
    Z       Buffer zone seat
  END

  ROW_PROPS= Hash[ <<-"END".lines.map {|l| l.strip.split(/\s+/, 2) } ]
    10      Row designated for RBD "A"
    11      Row designated for RBD "B"
    12      Row designated for RBD "C"
    13      Row designated for RBD "D"
    14      Row designated for RBD "F"
    15      Row designated for RBD "H"
    16      Row designated for RBD "J"
    17      Row designated for RBD "K"
    18      Row designated for RBD "L"
    19      Row designated for RBD "M"
    20      Row designated for RBD "P"
    21      Row designated for RBD "Q"
    23      Row designated for RBD "S"
    24      Row designated for RBD "T"
    25      Row designated for RBD "V"
    26      Row designated for RBD "W"
    27      Row designated for RBD "Y"
    B       Buffer row
    C       Row with cabin facilities in a designated column
    CC      Row with cabin facilities in an undesignated colum
    E       Exit row
    EC      Exit row with cabin facilities in a designated col
    EL      Exit left
    ER      Exit right
    I       Indifferent row
    K       Overwing row
    L       Lowerdeck row
    M       Maindeck row
    MV      Row with movie screen
    N       No-smoking row
    S       Smoking row
    U       Upperdeck row
    X       Not overwing row
    XC      Exit row with cabin facilities in an undesignated
    Z       Row does not exist
  END
end
