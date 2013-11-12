module Alfastrah
  class Segment
    include Virtus.value_object

    values do
      attribute :carrier_code, String
      attribute :flight_number, Fixnum
      attribute :origin_iata, String
      attribute :destination_iata, String
      attribute :depart_date, Date
      attribute :arrival_date, Date
    end
  end
end
