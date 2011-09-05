# encoding: utf-8
class Admin::CitiesController < Admin::ResourcesController
  include Admin::DecodingController
  self.sirena_dictionary = :city
  self.amadeus_dictionary = :dac

  def update_completer
    Completer.regen
    redirect_to :action => :list
  end
end
