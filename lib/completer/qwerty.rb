# encoding: utf-8
module Completer
  module Qwerty
    QWERTY = ('qwertyuiop[]' + 'QWERTYUIOP{}' +
      'asdfghjkl;\'' + 'ASDFGHJKL:"' +
      'zxcvbnm,./' + 'ZXCVBNM<>?')
    JCUKEN = ('йцукенгшщзхъ' + 'ЙЦУКЕНГШЩЗХЪ' +
      'фывапролджэ' + 'ФЫВАПРОЛДЖЭ' +
      'ячсмитьбю.' + 'ЯЧСМИТЬБЮ,').mb_chars
    QJ_MAP = Hash[QWERTY.chars.zip(JCUKEN.chars)]

    module_function

    def jcuken(s)
      s.mb_chars.chars.map {|c| QJ_MAP[c] || c }.join.mb_chars
    end

  end
end
