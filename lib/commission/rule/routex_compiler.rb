# encoding: utf-8

# компилирует штуки вида '...MOW,LED-US/OW,RT' в регексы
class Commission::Rule::RoutexCompiler

  VALID_FLAGS = %W[OW RT WO TR ALL].freeze

  def initialize(source)
    @source = source.upcase.strip
    raise ArgumentError, "#{@source.inspect} contains spaces" if @source[' ']
    @body, flags_string = @source.split('/')
    @flags = flags_string ? flags_string.split(',') : ['OW']
    @flags = %W[OW RT WO TR] if flags_string == 'ALL'
    @tokens = @body.split('-')
    validate!
  end

  def validate!
    @tokens.each do |token|
      if token[',']
        raise ArgumentError, "#{@source.inspect} contains alterations"
      elsif token.size != 3
        raise ArgumentError, "#{@source.inspect} contains countries"
      end
    end
    wrong_flags = (@flags - VALID_FLAGS)
    if wrong_flags.present?
      raise ArgumentError, "#{wrong_flags.inspect} flags in #{@source.inspect} are not supported"
    end
  end

  def compiled
    @flags.collect do |flag|
      case flag
      when 'OW'
        @tokens.join('-')
      when 'RT'
        (@tokens + @tokens.reverse[1..-1]).join('-')
      when 'WO'
        @tokens.reverse.join('-')
      when 'TR'
        (@tokens.reverse + @tokens[1..-1]).join('-')
      end
    end
  end
end
