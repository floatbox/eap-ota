# encoding: utf-8

DEFAULT = SMS::MFMS

module SMS
  def gate(*args)
    # на вход #gate можно давать common аттрибуты
    # для всех отсылаемых через него смс
    return @gate if args && @gate_args == args
    @gate_args = args
    @gate = DEFAULT.new(*args)
  end
end

