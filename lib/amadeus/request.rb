# encoding: utf-8
module Amadeus::Request

  def self.for action
    "::Amadeus::Request::#{action.camelize}".constantize
  # rescue NameError
  #  Amadeus::Request::Base
  end

  class Base

    include KeyValueInit
    attr_accessor :debug

    def action
      self.class.name.gsub(/^.*::/,'')
    end
  end

end
