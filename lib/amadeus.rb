require 'ostruct'
module Amadeus

  class Error < StandardError
  end

  def self.fake=(value); $amadeus_fake=value; end
  def self.fake; $amadeus_fake; end

  module Shortcuts
    def booking
      Amadeus::Service.new(:book => true, :office => Amadeus::Session::BOOKING)
    end

    def ticketing
      Amadeus::Service.new(:book => true, :office => Amadeus::Session::TICKETING)
    end
  end

  extend Shortcuts

end
