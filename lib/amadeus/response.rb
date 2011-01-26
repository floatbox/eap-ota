# encoding: utf-8
module Amadeus::Response

  # возможно, не самый эффективный способ сделать method_missing для классов
  def self.for action
    "::Amadeus::Response::#{action.camelize}".constantize
  rescue NameError
    Amadeus::Response::Base
  end

  # дебажные метод
  def self.latest_saved_for action
    self.for(action).new(Amadeus::Service.read_latest_doc(action))
  end

  def self.grep_saved action
    Amadeus::Service.read_each_doc(action) do |doc, path|
      response = self.for(action).new(doc)
      puts(path) if yield(response)
    end
  end

  class Base

    attr_accessor :doc

    def initialize(doc)
      @doc = doc
    end

    delegate :xpath, :to => :doc


    def or_fail!
      unless success?
        raise "#{self.class.name}: #{message}"
      end
      self
    end

    def success?
      errors.blank?
    end

    def message
      errors.join("; ")
    end

    def errors
      xpath('//r:errorMessage/r:errorMessageText/r:description').map(&:to_s)
    end

    def error_code
      xpath('//r:errorMessage/r:applicationError/r:applicationErrorDetail/r:error').to_s
    end

    def inspect
      "<#{self.class.name} #{success? ? 'Success' : 'Fail' }: #{message.presence && message.inspect}\n#{doc.to_xml.to_s}"
    end
  end
end
