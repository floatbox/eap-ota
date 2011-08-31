# encoding: utf-8
module Sirena
  module Response
    class ReturnTicket < Sirena::Response::Base
        attr_reader :tickets_returned

        def success?
            tickets_returned?
        end
    end
  end
end

