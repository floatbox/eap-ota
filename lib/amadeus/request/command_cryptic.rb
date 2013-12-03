module Amadeus
  module Request
    class CommandCryptic < Amadeus::Request::Base
      attr_accessor :command

      def summary
        command
      end
    end
  end
end
