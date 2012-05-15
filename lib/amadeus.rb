# encoding: utf-8
module Amadeus

  class Error < StandardError
  end

  module Shortcuts

    # FIXME как-то объединить бы код, что ли

    def booking
      amadeus = Amadeus::Service.new(:book => true, :office => Amadeus::Session::BOOKING)
      if block_given?
        begin
          return yield(amadeus)
        ensure
          amadeus.session.destroy
        end
      else
        return amadeus
      end
    end

    def ticketing
      amadeus = Amadeus::Service.new(:book => true, :office => Amadeus::Session::TICKETING)
      if block_given?
        begin
          return yield(amadeus)
        ensure
          amadeus.session.destroy
        end
      else
        return amadeus
      end
    end

    # еще копипаста!
    def testing
      amadeus = Amadeus::Service.new(:book => true, :office => Amadeus::Session::TESTING)
      if block_given?
        begin
          return yield(amadeus)
        ensure
          amadeus.session.destroy
        end
      else
        return amadeus
      end
    end
  end

  extend Shortcuts

end
