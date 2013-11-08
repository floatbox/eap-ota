# encoding: utf-8

DEFAULT = SMS::MFMS

module SMS
  def gate(*args)
    return @gate if args && @gate_args == args
    @gate_args = args
    @gate = DEFAULT.new(*args)
  end
end

