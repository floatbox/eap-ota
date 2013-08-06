# encoding: utf-8
class Commission::Reader::Rule

  attr_accessor :opts

  def initialize(page = Commission::Page.new)
    @page = page
    @opts = {}
    @default_opts = Commission::Reader::READER_DEFAULTS.dup
  end

  # TODO внятно среагировать на отсутствие блока
  def define(attrs={}, &block)
    # модифицирует @opts
    instance_eval(&block)
    attrs = attrs.merge(@opts).reverse_merge(@default_opts)
    attrs[:source] ||= caller_address
    @page.create_rule(attrs)
  end

  def no_commission reason=true
    @opts[:no_commission] = reason
  end

  # выключает правило
  def disabled reason=true
    @opts[:disabled] = reason
  end

  def not_implemented reason=true
    @opts[:not_implemented] = reason
  end

  # строчки из агентского договора (FM, комиссии, указываемые в бронировании)
  def agent_comment line
    @opts[:agent_comments] ||= ""
    @opts[:agent_comments] += line + "\n"
  end

  # строчки из субагентского договора (маржа, которую мы оставим себе от fare)
  def subagent_comment line
    @opts[:subagent_comments] ||= ""
    @opts[:subagent_comments] += line + "\n"
  end

  # произвольные комментарии к правилу
  def comment line
    @opts[:comments] ||= ""
    @opts[:comments] += line + "\n"
  end

  # tkt designator, используется при выписке в downtown
  def designator designator
    @opts[:designator] = designator
  end

  # туркод, используется при выписке в downtown
  def tour_code tour_code
    @opts[:tour_code] = tour_code
  end

  # правило интерлайна
  def interline *values
    @opts[:interline] = values
  end

  # внутренние авиалинии
  def domestic
    @opts[:domestic] = true
  end

  # внешние авиалинии
  def international
    @opts[:international] = true
  end

  # пока принимает уже готовый массив
  def routes *routes
    @opts[:routes] = routes
  end

  def subclasses *subclasses
    @opts[:subclasses] = subclasses.join.upcase.gsub(' ', '').split('')
  end

  def classes *classes
    @opts[:classes] = classes
  end

  def important!
    @opts[:important] = true
  end

  def example str
    @opts[:examples] ||= []
    @opts[:examples] << [str, caller_address]
  end

  def check(check_text=nil, &block)
    raise ArgumentError, "check block should be given as String" unless check_text
    block_text =
      "lambda do |recommendation|
        #{ check_text }
      end"
    # сдвиг (- 5) подобран руками для тестов. но в комиссиях срабатывает - 1. почему?
    block = eval(block_text, nil, caller_file, caller_line - 1) if check_text
    @opts[:check] = check_text || '# COMPILED'
    @opts[:check_proc] = block
  end

  # дополнительные опции, пока без обработки
  def system value
    @opts[:system] = value
  end

  def ticketing_method value
    @opts[:ticketing_method] = value
  end

  def agent value
    @opts[:agent] = value
  end

  def subagent value
    @opts[:subagent] = value
  end

  def consolidator value
    @opts[:consolidator] = value
  end

  def blanks value
    @opts[:blanks] = value
  end

  def discount value
    @opts[:discount] = value
  end

  def our_markup value
    @opts[:our_markup] = value
  end

  private

  def caller_address level=1
    caller[level] =~ /^(.*?:\d+)/
    # по каким-то причинам тут приходит US-ASCII
    # конвертирую для yaml
    ($1 || 'unknown').encode('UTF-8')
  end

  def caller_file level=1
    caller[level].split(':')[0]
  end

  def caller_line level=1
    caller[level].split(':')[1].to_i
  end
end
