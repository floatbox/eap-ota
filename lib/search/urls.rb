# encoding: utf-8

module Search
  module Urls
    module Defaults
      CABIN = 'Y'
      ADULTS = 1
      CHILDREN = 0
      INFANTS = 0
    end
  end
end

require 'search/urls/decoder'
require 'search/urls/encoder'

