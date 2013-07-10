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

  # проверка на наличие перечислений, "любых городов" и стран на маршруте
  # иначе достаточно простого текстового сравнения
  def regex_needed?
    @body[','] || @body['...'] || @body =~ /\b\w{2}\b/
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
        regexp_tokens =
          compiled_tokens.collect do |token|
            if token == '-'
              token
            elsif token == '...'
              '.*?'
            else
              alts = token.split(',').flat_map {|token| expand_aliases(token)}
              if alts.size == 1
                alts.first
              else
                '(' + alts.join('|') + ')'
              end
            end
          end

        if regexp_tokens.first == '.*?'
          regexp_tokens.shift
        else
          regexp_tokens.unshift '^'
        end

        if regexp_tokens.last == '.*?'
          regexp_tokens.pop
        else
          regexp_tokens.push '$'
        end

        Regexp.compile( regexp_tokens.join )
      else
        compiled_tokens.join
      end

    end
  end

  private

  def expand_aliases(token)
    if token.size == 3
      # город
      return token
    elsif token.size == 2
      return Country[token].city_iatas
    else
      raise ArgumentError, "#{@source.inspect} contains  unknown subtoken #{token}"
    end
  end
end
