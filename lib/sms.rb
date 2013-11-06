# encoding: utf-8

DEFAULT = SMS::MFMS

module SMS
  class Message
    def valid?(message_body)
      # длина смс с кириллицей - 70 символов
      # без - 160 символов
      max_length = message_body =~ /\P{ASCII}/ ? 70 : 160
      message_body.length <= max_length
    end

  end

  def gate(*args)
    return @gate if args && @gate_args == args
    @gate_args = args
    @gate = DEFAULT.new(*args)
  end

end

