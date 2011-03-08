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
        unless (error = xpath('//error')).blank?
          error.map(&:text).join("; ")
        end
      end

      def to_amadeus_time(str)
        if str.length < 5
          str="0"+str
        end
        str.gsub(":", "")
      end
    end
  end
end
