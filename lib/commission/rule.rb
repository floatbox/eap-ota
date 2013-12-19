# encoding: utf-8
#
# комиссионное правило. Просто тупой контейнер для параметров правила.
class Commission::Rule

  include Commission::Rule::Matching
  include KeyValueInit
  extend Commission::Attrs

  # @!group Общие для блока комиссий свойства.

  # IATA перевозчика
  # @return [String]
  attr_accessor :carrier

  # GDS
  # @note сейчас нигде не используется
  # @return [Symbol] :amadeus
  attr_accessor :system

  # @!group Тип комиссионного правила.
  # FIXME документировать разницу

  # причина отключения продаж по этому правилу
  # @return [Boolean, String]
  attr_accessor :disabled

  # проблема, не дающая закончить правило
  # @return [Boolean, String]
  attr_accessor :not_implemented

  # заглушка для экзамплов, которые не должны сработать
  # @return [Boolean, String]
  attr_accessor :no_commission

  # @!group Предикаты. Определяют применимость правила внутри блока.

  # тип интерлайна
  # @return [Array<Symbol>] :no, :yes, :half, :less_than_half, :absent, :unconfirmed
  attr_accessor :interline

  # перелеты только внутри одной страны
  # @return [Boolean]
  attr_accessor :domestic

  # пересекает границу
  # @return [Boolean]
  attr_accessor :international

  # массив разрешенных классов бронирования, :economy, :business, :first
  # @return [Array<Symbol>]
  attr_accessor :classes

  # массив букв подклассов бронирования
  # @return [Array<String>]
  attr_accessor :subclasses

  # маршруты, на которых применимо правило.
  # @note FIXME никто не использует. научить!
  # @return [Array<String>]
  attr_reader :routes

  # скомпилированные до регексов маршруты, один из которых должен подойти
  # @return [Array<String,Regexp>]
  attr_reader :compiled_positive_routes

  # скомпилированные до регексов маршруты, ни один из которых не должен подойти
  # @return [Array<String,Regexp>]
  attr_reader :compiled_negative_routes

  # последнее средство сравнения - текст блока на ruby.
  # будет выполнен в контексте рекомендации.
  # должен вернуть true, если рекомендация подходит.
  # @return [String]
  attr_accessor :check

  # скомпилированный и закэшированный check
  # @return [Proc]
  attr_accessor :check_proc

  # правило проверяется выносится в начало цепочки проверок, даже если определено
  # последним.
  # @return [Boolean]
  attr_accessor :important

  # @!group Полезная нагрузка найденной комиссии.

  # формула для расчета суммы, которую берет агент
  # @return [Commission::Formula]
  has_commission_attrs :agent

  # формула для расчета суммы, которую берет посредник между агентом и нами
  # @return [Commission::Formula]
  has_commission_attrs :subagent

  # формула для расчета коммиссии консолидатора - посредника между нами и авиакомпанией
  # aviacenter и downtown - консолидаторы
  # @return [Commission::Formula]
  has_commission_attrs :consolidator

  # формула для расчета сбора за бланки, используется для сирены
  # @return [Commission::Formula]
  has_commission_attrs :blanks

  # рекомендуемый метод выписки.
  # @return [String] "aviacenter", "downtown", "direct"
  attr_accessor :ticketing_method

  # текст правила из агентского договора
  # @return [String]
  attr_accessor :agent_comments

  # текст правила из субагентского договора
  # @return [String]
  attr_accessor :subagent_comments

  # текст наших комментариев, для внутреннего пользования
  # @return [String]
  attr_accessor :comments

  # ремарка для выписки некоторых авиакомпаний в downtown
  # @return [String]
  attr_accessor :designator

  # ремарка для выписки некоторых авиакомпаний в downtown
  # @return [String]
  attr_accessor :tour_code

  # @!group Дебажная информация

  # место (сейчас - имя файла и строка комиссиий) где было определено правило
  # @return [String]
  attr_accessor :source

  # порядковый номер комиссии в блоке
  # @return [Fixnum]
  attr_accessor :number

  # массив примеров рекомендаций, которые должны получить именно эту комиссию.
  # @return [Array<Commission::Example>]
  attr_reader :examples

  # @!endgroup

  def examples=(example_array)
    @examples = example_array.collect do |code, source|
      Commission::Example.new( code: code, source: source, commission: self )
    end
  end

  def routes=(routex_array)
    @routes = routex_array
    @compiled_positive_routes = []
    @compiled_negative_routes = []
    routex_array.each do |routex|
      compiler = Commission::Rule::RoutexCompiler.new(routex)
      @compiled_positive_routes += compiler.compiled_positive
      @compiled_negative_routes += compiler.compiled_negative
    end
  end

  def inspect
    "<Commission::Rule #{carrier}##{number} at #{source}>"
  end

end
