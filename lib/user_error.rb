# encoding: utf-8
#
# Ошибка ввода пользователя. Исчезнет при вводе других данных.
#
# see http://avdi.org/talks/exceptional-ruby-2011-02-04/
class UserError < StandardError
  include Errors::Nested
end
