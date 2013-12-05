# encoding: utf-8
#
# "file:line" of caller, useful in constructors, inspectors and so on.
module CallerAddress

  private

  def caller_address level=1
    caller[level] =~ /^(.*?:\d+)/
    # по каким-то причинам тут приходит US-ASCII
    # конвертирую для yaml
    ($1 || 'unknown').encode('UTF-8')
  end
end
