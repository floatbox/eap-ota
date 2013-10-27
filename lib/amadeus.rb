# encoding: utf-8
require 'amadeus/errors'
module Amadeus

  module OfficeShortcuts
    # возвращает office_id для алиаса в конфиге, типа BOOKING и т.п.
    # возвращает строку, если передан уже готовый OFFICE_ID
    # TODO caching.
    def office(al)
      al = al.to_s
      # MOWR228FA, MOWR2233B etc.
      return al if al =~ /\A[A-Z\d]{9}\z/
      Conf.amadeus.offices.each do |office, settings|
        return office if settings["alias"] == al.to_s
      end
      raise ArgumentError, "no office_id defined for alias #{al}"
    end
  end

  extend OfficeShortcuts

  module Shortcuts

    def session(office)
      amadeus = Amadeus::Service.new(:book => true, :office => office)
      if block_given?
        begin
          return yield(amadeus)
        ensure
          amadeus.destroy
        end
      else
        return amadeus
      end
    end

    # TODO переименовать это все в соответствии с назначением

    def booking(&block)
      session(office(:booking), &block)
    end

    def ticketing(&block)
      session(office(:ticketing), &block)
    end

    def downtown(&block)
      session(office(:downtown), &block)
    end

    def zagorye(&block)
      session(office(:zagorye), &block)
    end
  end

  extend Shortcuts

end
