# encoding: utf-8
# ходим за справочниками в амадеус и сирену
module Admin
  module DecodingController

    extend ActiveSupport::Concern

    included do
      cattr_accessor :amadeus_dictionary
      cattr_accessor :sirena_dictionary
    end

    def decode_amadeus
      get_object
      if @item.iata.present?
        render :text => Amadeus.booking {|a| a.cmd_full("#{amadeus_dictionary} #{@item.iata}") }
      end
    rescue => e
      render :text => e.message
    end

    def decode_sirena
      get_object
      if @item.iata_ru.present?
        render :text => Sirena::Service.new.describe( sirena_dictionary, :code => @item.iata_ru).as_yaml
      end
    rescue => e
      render :text => e.message
    end
  end
end
