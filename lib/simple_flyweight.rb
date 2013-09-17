# encoding: utf-8
#
# Очень, очень простое кэширование immutable объектов.
# Кэш не очищается, бойтесь утечек!
#
# @example Usage
#   class Foo
#     extend SimpleFlyweight
#     ...
#   end
#
#   Foo.new(3).object_id == Foo.new(3).object_id
#   => 3
module SimpleFlyweight
  def new(*args)
    @pool ||= {}
    @pool[args] ||= super
  end

  def clear_cache
    @pool = {}
  end
end
