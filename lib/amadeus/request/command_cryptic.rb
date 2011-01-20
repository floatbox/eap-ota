module Amadeus
  module Request
    class CommandCryptic < Amadeus::Request::Base
      attr_accessor :command
    end
  end
end