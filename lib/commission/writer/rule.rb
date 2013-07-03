# encoding: utf-8
class Commission::Writer::Rule

  WRITER_DEFAULTS = Commission::Reader::READER_DEFAULTS

  def initialize(rule)
    @rule = rule
  end

  def write
    str = ""

    @rule.examples.each do |ex|
      str << %[example #{ex.to_s.inspect}\n]
    end if @rule.examples.present?

    @rule.comments.split("\n").each do |line|
      str << %[comment #{line.inspect}\n]
    end if @rule.comments

    @rule.agent_comments.split("\n").each do |line|
      str << %[agent #{line.inspect}\n]
    end if @rule.agent_comments

    @rule.subagent_comments.split("\n").each do |line|
      str << %[subagent #{line.inspect}\n]
    end if @rule.subagent_comments

    if @rule.interline != WRITER_DEFAULTS[:interline]
      str << %[interline #{@rule.interline.map(&:inspect).join(", ")}\n]
    end

    if @rule.classes
      str << %[classes #{@rule.classes.map(&:inspect).join(", ")}\n]
    end

    if @rule.subclasses
      str << %[subclasses #{@rule.subclasses.join.inspect}\n]
    end

    if @rule.routes
      str << %[subclasses #{@rule.routes.map(&:inspect).join(", ")}\n]
    end

    str << %[important!\n] if @rule.important

    str << %[domestic\n] if @rule.domestic
    str << %[international\n] if @rule.international


    str << commission_if_needed(:consolidator)
    str << commission_if_needed(:blanks)
    str << commission_if_needed(:discount)
    str << commission_if_needed(:our_markup)

    if @rule.ticketing_method
      str << %[ticketing_method #{@rule.ticketing_method.inspect}\n]
    end

    if @rule.check
      if @rule.check['\\']
        raise ArgumentError, "check in #{@rule.inspect} contains backslashes"
      end
      # FIXME проверить еще на парность скобок
      str << %[check %{#{@rule.check}}\n]
    end

    str << bool_or_reason("disabled", @rule.disabled)
    str << bool_or_reason("not_implemented", @rule.not_implemented)

    if @rule.no_commission
      if @rule.no_commission.is_a? String
        str << %[no_commission #{@rule.no_commission.inspect}\n]
      else
        str << %[no_commission\n]
      end
    else
      str << %[commission "#{@rule.agent}/#{@rule.subagent}"\n]
    end
    str
  end

  private

    def bool_or_reason token, value
      return "" unless value
      if value.is_a? String
        %[#{token} #{value.inspect}\n]
      else
        %[#{token}\n]
      end
    end

    def commission_if_needed token
      fx = @rule.send token
      return "" if fx == Commission::Formula.new( WRITER_DEFAULTS[token] )
      %[#{token} #{fx.to_s.inspect}\n]
    end

end
