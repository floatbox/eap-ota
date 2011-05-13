# encoding: utf-8
module Sirena
  module Request
    class Describe < Sirena::Request::Base
      attr_accessor :data, :code, :show_all, :company, :show_real_codes

      TYPES = %W[ aircompany airport city country passenger document tax vehicle
        pcards pcard_types region meal fop ]

      def initialize(data=nil, args={})
        raise ArgumentError, "first arg should be one of [#{TYPES.join(' ')}]"  unless TYPES.include?(data.to_s)
        self.data = data
        super args
      end

    end
  end
end
