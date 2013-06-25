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
  # @return [Symbol] :amadeus, :sirena
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
  attr_accessor :routes

  # дата начала действия правила
  # @return [Date]
  attr_accessor :expr_date

  # дата окончания действия правила
  # @return [Date]
  attr_accessor :strt_date

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

  # формула для расчета скидки, считается на основе тарифа
  # @return [Commission::Formula]
  has_commission_attrs :discount

  # формула для расчета нашей надбавки к стоимости
  # @return [Commission::Formula]
  has_commission_attrs :our_markup

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

  # ремарка для выписки некоторых авиакомпаний в downtown
  # @return [String]
  attr_accessor :designator

  # ремарка для выписки некоторых авиакомпаний в downtown
  # @return [String]
  attr_accessor :tour_code

  # @!group Дебажная информация

  # место (сейчас - номер строки в файле комиссиий) где было определено правило
  # @return [String]
  attr_accessor :source

  # порядковый номер комиссии в блоке
  # @return [Fixnum]
  attr_accessor :number

  # поправляет комиссию в соответствии с вычисленными дефолтами.
  # @see Commission::Correctors
  # @note TODO попробовать избавиться.
  # @return [Symbol]
  attr_accessor :corrector

  # массив примеров рекомендаций, которые должны получить именно эту комиссию.
  # @return [Array<Commission::Example>]
  attr_reader :examples

  # @!endgroup

  def initialize(*)
    # дефолты
    @interline = [:no]
    super
  end

  def examples=(example_array)
    @examples = example_array.collect do |code, source|
      Commission::Example.new( code: code, source: source, commission: self )
    end
  end

  def inspect
    "<commission #{carrier}##{number} :#{source}>"
  end

  # @note FIXME документировать
  def correct!
    # FIXME временно выключаю, потому что корректоры у нас пока работают только с числами
    # а их тут нет.
    Commission::Correctors.apply(self, corrector)
  end

end
