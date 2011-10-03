# encoding: utf-8
class Admin::AirportsController < Admin::EviterraResourceController
  include Admin::DecodingController
  self.sirena_dictionary = :airport
  self.amadeus_dictionary = :dac

  def update_completer
    Completer.regen
    redirect_to :action => :list
  end
end
