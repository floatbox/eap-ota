# encoding: utf-8
class Admin::AirplanesController < Admin::EviterraResourceController
  include Admin::DecodingController
  self.amadeus_dictionary = :dne

  def show_versions
    get_object
  end
end
