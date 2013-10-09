# encoding: utf-8
require 'amadeus/errors'
module Amadeus

  module Shortcuts

    def session(office)
      amadeus = Amadeus::Service.new(:book => true, :office => office)
      if block_given?
        begin
          return yield(amadeus)
        ensure
          amadeus.destroy
        end
      else
        return amadeus
      end
    end

    # TODO переименовать это все в соответствии с назначением

    def booking(&block)
      session(Amadeus::Session::BOOKING, &block)
    end

    def ticketing(&block)
      session(Amadeus::Session::TICKETING, &block)
    end

    def downtown(&block)
      session(Amadeus::Session::DOWNTOWN, &block)
    end

    def zagorye(&block)
      session(Amadeus::Session::ZAGORYE, &block)
    end
  end

  extend Shortcuts

end
