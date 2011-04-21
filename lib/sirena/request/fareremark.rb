# encoding: utf-8
module Sirena
  module Request
    class Fareremark < Sirena::Request::Base
      attr_accessor :company, :code, :upt
      def initialize(recommendation)
        # FIXME надо где-то в другом месте брать company
        # на самом деле, но пока нет интерлайнов, сойдет
        # также что-то другое делать, если несколько упт
        @company = recommendation.validating_carrier_iata
        @code = recommendation.upts.keys[0]
        @upt = recommendation.upts[@code]
      end
    end
  end
end