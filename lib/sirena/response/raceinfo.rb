module Sirena
  module Response
    class Raceinfo < Sirena::Response::Base
      attr_accessor :flight

      def parse
        @flight = Flight.new(
          :flight_number => xpath("//raceinfo")[0]["num"],
          :operating_carrier_iata => xpath("//raceinfo")[0]["acomp"],
          :marketing_carrier_iata  => xpath("//raceinfo")[0]["acomp"],
          :departure_date => xpath("//raceinfo")[0]["date"].gsub('.', ''),
          :arrival_time => corrected_time(xpath('//arrvtime').text),
          :departure_time => corrected_time(xpath('//depttime').text),
          :arrival_iata => xpath('//arrival')[0]['port'] || xpath('//arrival').text,
          :departure_iata => xpath('//departure')[0]['port'] || xpath('//departure').text
        )
        @flight.arrival_date = if @flight.departure_time < @flight.arrival_time
          @flight.departure_date
        else
          (@flight.dept_date + 1.day).strftime('%d%m%y')
        end
      end

      def corrected_time(time)
        if time.length == 4
          '0' + time.gsub(':', '')
        else
          time.gsub(':', '')
        end
      end
    end
  end
end

