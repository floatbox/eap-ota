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

    # теперь это приватный метод? хм.
    def xpath(*args)
      doc.send(:xpath, *args)
    end

    def parse_date_element elem
      return unless elem.present?
      year = (elem / "r:year").to_i
      month = (elem / "r:month").to_i
      day = (elem / "r:day").to_i
      if [year, month, day].all?
        Date.new(year, month, day)
      else
        nil
      end

    end


    def or_fail!
      unless success?
        raise Amadeus::Error, "#{self.class.name}: #{error_message}"
      end
      self
    end

    def success?
      error_message.blank?
    end

    def error_message
      nil
    end

    def inspect
      "<#{self.class.name} #{success? ? 'Success' : 'Fail' }: #{error_message.presence && error_message.inspect}\n#{doc.to_xml.to_s}"
    end
  end
end

