# encoding: utf-8
module Sirena
  module Response

    def self.for action
      "::Sirena::Response::#{action.camelize}".constantize
    rescue NameError
      Sirena::Response::Base
    end

    class Base
      attr_accessor :doc

      def initialize(xml)
        # TODO имеет ли смысл использовать QueryFront?
        # @doc = Handsoap::XmlQueryFront.parse_string(xml_string, :nokogiri)
        @doc = Nokogiri::XML::Document.parse(xml)
      end

      delegate :xpath, :to_s, :to => :doc

      # а везде такой метод?
      def error
        if error = xpath('//error')
          error.text
        end
      end

    end
  end
end
