# encoding: utf-8
module Sirena
  module Response
    class Fareremark < Sirena::Response::Base
      attr_accessor :text
      def parse
        @text = xpath("//remark").text
      end
    end
  end
end