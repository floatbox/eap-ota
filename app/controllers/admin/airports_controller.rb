# encoding: utf-8
class Admin::AirportsController < Admin::EviterraResourceController
  include Admin::DecodingController
  self.amadeus_dictionary = :dac

  def update_completer
    Completer.regen
    redirect_to :action => :list
  end

  def show_versions
    get_object
  end
end
