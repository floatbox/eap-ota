# encoding: utf-8
module Completer
  module Normalizer
    NONWORD = /[^[:alnum:]]+/
    def normalize(word)
      ::Unicode.downcase(word).gsub(NONWORD, ' ').strip
    end
  end
end
