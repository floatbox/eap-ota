module Amadeus::Response

  # возможно, не самый эффективный способ сделать method_missing для классов
  def self.for action
    "::Amadeus::Response::#{action.camelize}".constantize
  rescue NameError
    Amadeus::Response::Base
  end

  class Base

    attr_accessor :doc

    def initialize(doc)
      @doc = doc
    end

    delegate :xpath, :to => :doc


    def bang!
      unless success?
        raise "#{self.class.name}: #{message}"
      end
      self
    end

    def success?
      true
    end

    def message
      nil
    end

    def inspect
      "<#{self.class.name} #{success? ? 'Success' : 'Fail' }: #{message.presence && message.inspect}\n#{doc.to_xml.to_s}"
    end
  end
end
