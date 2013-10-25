# encoding: utf-8
class Admin::CarriersController < Admin::EviterraResourceController
  include Admin::DecodingController
  self.amadeus_dictionary = :dna

  def show_versions
    get_object
  end
end
