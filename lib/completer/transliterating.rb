# encoding: utf-8
require 'completer/old_school'
# FIXME russian и правда нужен?
require 'russian'
require 'completer/qwerty'
module Completer
  class Transliterating < OldSchool
    def complete(string, opts={})
      super(string, opts).presence ||
        super(Qwerty.jcuken(string), opts)
    end
  end
end
