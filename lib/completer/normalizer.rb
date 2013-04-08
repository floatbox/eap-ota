# encoding: utf-8
class Completer
  module Normalizer
    NONWORD = /[^[:alnum:]]+/
    def normalize(word)
      word.mb_chars.downcase.gsub(NONWORD, ' ').strip
    end
  end
end
