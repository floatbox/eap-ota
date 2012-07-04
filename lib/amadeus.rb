# encoding: utf-8
module Amadeus

  class Error < StandardError
  end

  module Shortcuts

    def session(office)
      amadeus = Amadeus::Service.new(:book => true, :office => office)
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

    def booking(&block)
      session(Amadeus::Session::BOOKING, &block)
    end

    def ticketing(&block)
      session(Amadeus::Session::TICKETING, &block)
    end

    def testing(&block)
      session(Amadeus::Session::TESTING, &block)
    end
  end

  extend Shortcuts

end
