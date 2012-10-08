# encoding: utf-8
class JoinedArray
  # TODO параметры?
  def initialize
    @separator = ' '
  end

  def load(string)
    string.to_s.split(@separator)
  end

  def dump(array)
    array.join(@separator)
  end
end
