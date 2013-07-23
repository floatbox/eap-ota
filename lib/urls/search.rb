# encoding: utf-8

module Urls
  module Search
    module Defaults
      CABIN = 'Y'
      ADULTS = 1
      CHILDREN = 0
      INFANTS = 0
    end
  end
end

require 'urls/search/decoder'
require 'urls/search/encoder'

