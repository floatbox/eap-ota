# encoding: utf-8
module Sirena
  module Request

    def self.for action
      "::Sirena::Request::#{action.camelize}".constantize
    # rescue NameError
    #   Sirena::Request::Base
    end

    class Base

      include KeyValueInit

      def render
        %(<?xml version="1.0" encoding="UTF-8"?>\n) +
        %(<sirena>\n) +
        %(<query>\n) +
        query_body +
        %(</query>\n) +
        %(</sirena>\n)
      end

      def query_body
        template = template_for_action
        Haml::Engine.new( File.read(template),
          :autoclose => [],
          :preserve => [],
          :filename => template,
          :ugly => false,
          :escape_html => true
        ).render(self)
      end

      def template_for_action
        File.expand_path("../templates/#{action.underscore}.haml", __FILE__)
      end

      def action
        self.class.name.gsub(/^.*::/,'')
      end

      # сделать оверрайд где это нужно
      def encrypt?
        false
      end

      def priority
        2
      end

      def timeout
        40
      end

      def process_response(response_body)
        Sirena::Response.for(action).new(response_body)
      end

      # helpers

      # TODO на наших датах всегда работает?
      def sirena_date(date)
        date.dup.insert(4, ".20").insert(2, ".")
      end
    end
  end
end
