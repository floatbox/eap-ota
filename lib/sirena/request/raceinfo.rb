# encoding: utf-8
module Sirena
  module Request
    # не имеет парсера и не используется на сайте, пока что.
    # Sirena::Service.new.raceinfo(:carrier => 'R3', :flight => 731, :date => Date.tomorrow)
    class Raceinfo < Sirena::Request::Base
      attr_accessor :carrier, :flight, :date
    end
  end
end
