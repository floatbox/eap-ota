# encoding: utf-8
# ходим за справочниками в амадеус и сирену
module Admin
  module DecodingController

    extend ActiveSupport::Concern

    included do
      cattr_accessor :amadeus_dictionary
    end

    def decode_amadeus
      get_object
      if @item.iata.present?
        render :text => Amadeus.booking {|a| a.cmd_full("#{amadeus_dictionary} #{@item.iata}") }
      end
    rescue => e
      render :text => e.message
    end

  end
end
