# encoding: utf-8
class Admin::CarriersController < Admin::EviterraResourceController
  include Admin::DecodingController
  self.sirena_dictionary = :aircompany
  self.amadeus_dictionary = :dna
end
