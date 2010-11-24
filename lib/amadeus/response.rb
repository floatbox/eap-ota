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

  end
end
