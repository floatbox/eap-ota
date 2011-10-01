# encoding: utf-8
class Admin::AirplanesController < Admin::EviterraResourceController
  include Admin::DecodingController
  self.sirena_dictionary = :vehicle
  self.amadeus_dictionary = :dne
end
