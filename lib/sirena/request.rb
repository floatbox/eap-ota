# encoding: utf-8
module Sirena
  module Request

    def self.for action
      "::Sirena::Request::#{action.camelize}".constantize
    # rescue NameError
    #   Sirena::Request::Base
    end

    class Base
      def render
        template = template_for_action

        %(<?xml version="1.0" encoding="UTF-8"?>\n) +
        %(<query>\n) +
        %(<sirena>\n) +

        Haml::Engine.new( File.read(template),
          :autoclose => [],
          :preserve => [],
          :filename => template,
          :ugly => false,
          :escape_html => true
        ).render(self) +

        %(</sirena>\n) +
        %(</query>\n)
      end

      def template_for_action
        File.expand_path("../templates/#{action.underscore}.haml", __FILE__)
      end

      def action
        self.class.name.gsub(/^.*::/,'')
      end

      # helpers

      # TODO на наших датах всегда работает?
      def sirena_date(date)
        date.dup.insert(4, ".20").insert(2, ".")
      end
    end
  end
end
