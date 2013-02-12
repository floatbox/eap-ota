# очень, очень простое кэширование immutable объектов
# кэш не очищается, бойтесь утечек!
#
# Usage:
#   class Foo
#     extend SimpleFlyweight
#   end
module SimpleFlyweight
  def new(*args)
    @pool ||= {}
    @pool[args] ||= super
  end
end
