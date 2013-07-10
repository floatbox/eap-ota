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
    @tokens = @body.split(/(-|\.\.\.)/)
    validate!
  end

  def validate!
    wrong_flags = (@flags - VALID_FLAGS)
    if wrong_flags.present?
      raise ArgumentError, "#{wrong_flags.inspect} flags in #{@source.inspect} are not supported"
    end
  end

  def regex_needed?
    @body[','] || @body['...']
  end

  def compiled
    @flags.collect do |flag|
      compiled_tokens =
        case flag
        when 'OW'
          @tokens
        when 'RT'
          (@tokens + @tokens.reverse[1..-1])
        when 'WO'
          @tokens.reverse
        when 'TR'
          (@tokens.reverse + @tokens[1..-1])
        end

      if regex_needed?
        Regexp.compile(
          '^' +
          compiled_tokens.collect do |token|
            if token[',']
              '(' + token.split(',').join('|') + ')'
            else
              token
            end
          end.join +
          '$'
        )
      else
        compiled_tokens.join
      end

    end
  end
end
