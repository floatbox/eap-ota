# encoding: utf-8
module Amadeus

  class Error < StandardError
  end

  def self.fake=(value); $amadeus_fake=value; end
  def self.fake; $amadeus_fake; end

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
  end

  extend Shortcuts

end
