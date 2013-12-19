# encoding: utf-8
class Commission::Writer::Rule

  WRITER_DEFAULTS = Commission::Reader::READER_DEFAULTS

  def initialize(rule)
    @rule = rule
  end

  def write
    clear_buffer

    line %[rule #{@rule.number} do]

    # в каком порядке проверять, и проверять ли вообще данное правило?

    line bool_or_reason("disabled", @rule.disabled)
    line bool_or_reason("not_implemented", @rule.not_implemented)
    line bool_or_reason("no_commission", @rule.no_commission)

    @rule.important and
      line %[important!]

    # полезная нагрузка: метод выписки, формулы, комментарии

    @rule.ticketing_method and
      line %[ticketing_method #{@rule.ticketing_method.inspect}]

    line commission_unless_blank(:agent)
    line commission_unless_blank(:subagent)
    line commission_if_needed(:consolidator)
    line commission_if_needed(:blanks)

    @rule.tour_code and
      line %[tour_code #{@rule.tour_code.inspect}]
    @rule.designator and
      line %[designator #{@rule.designator.inspect}]

    lines 'comment', @rule.comments
    lines 'agent_comment', @rule.agent_comments
    lines 'subagent_comment', @rule.subagent_comments

    # свойства для сверки с рекомендацией

    @rule.interline != WRITER_DEFAULTS[:interline] and
      line %[interline #{@rule.interline.map(&:inspect).join(", ")}]

    @rule.classes and
      line %[classes #{@rule.classes.map(&:inspect).join(", ")}]

    @rule.subclasses and
      line %[subclasses #{@rule.subclasses.join.inspect}]

    @rule.routes and
      line %[routes #{@rule.routes.map(&:inspect).join(", ")}]

    @rule.domestic and
      line %[domestic]
    @rule.international and
      line %[international]

    if @rule.check
      if @rule.check['\\']
        raise ArgumentError, "check in #{@rule.inspect} contains backslashes"
      end
      # FIXME проверить еще на парность скобок
      line %[check %{#{@rule.check}}]
    end

    # отладка: примеры

    Array(@rule.examples).each do |ex|
      line %[example #{ex.to_s.inspect}]
    end

    line %[end]

    buffer
  end

  private

    def bool_or_reason token, value
      return unless value
      if value.is_a? String
        %[#{token} #{value.inspect}]
      else
        token
      end
    end

    def commission_if_needed token
      fx = @rule.send token
      return if fx == Commission::Formula.new( WRITER_DEFAULTS[token] )
      %[#{token} #{fx.to_s.inspect}]
    end

    def commission_unless_blank token
      fx = @rule.send token
      return if fx.blank?
      %[#{token} #{fx.to_s.inspect}]
    end

    def buffer
      @buffer
    end

    def clear_buffer
      @buffer = ""
    end

    def line(arg)
      @buffer << "#{arg}\n" if arg
    end

    def lines(arg, multiline_value)
      return unless multiline_value
      multiline_value.split("\n").each do |l|
        line %[#{arg} #{l.inspect}]
      end
    end

end
