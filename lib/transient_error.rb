# encoding: utf-8
#
# Временная ошибка. Таймауты, дисконнекты, и прочее.
# чаще всего, можно сделать retry
#
# see http://avdi.org/talks/exceptional-ruby-2011-02-04/
class TransientError < StandardError
  include Nesty::NestedError
end
