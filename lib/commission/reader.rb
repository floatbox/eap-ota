# encoding: utf-8

# "считыватель" для Commission::Book, старый синтаксис
class Commission::Reader

  attr_accessor :opts
  attr_accessor :default_opts
  attr_accessor :carrier_default_opts
  attr_accessor :book

  def initialize(book = Commission::Book.new)
    self.book = book
    self.default_opts = {}
    self.carrier_default_opts = {}
  end

  # выполняет определения в блоке и возвращает готовую "книгу"
  def define(&block)
    instance_eval(&block)
    book
  end

  # считывает определения из файла и возвращает готовую "книгу"
  def read_file(filename)
    instance_eval(File.read(filename), filename)
    book
  end

  ALLOWED_KEYS_FOR_DEFS = %W[
    system ticketing_method consolidator blanks discount our_markup
    corrector disabled not_implemented no_commission
  ].map(&:to_sym)

  def defaults def_opts={}
    def_opts.to_options!.assert_valid_keys(ALLOWED_KEYS_FOR_DEFS)
    self.default_opts = def_opts
  end

  def carrier_defaults def_opts={}
    def_opts.to_options!.assert_valid_keys(ALLOWED_KEYS_FOR_DEFS)
    self.carrier_default_opts = def_opts
  end

  def carrier carrier, carrier_name=nil
    if carrier =~ /\A..\Z/
      @carrier = carrier
      @carrier_name = carrier_name
      self.opts={}
      self.carrier_default_opts={}
      @last_commission_number = 1
    else
      raise ArgumentError, "strange carrier: #{carrier}"
    end
  end

  # один аргумент, разделенный пробелами или /; или два аргумента
  def commission arg
    vals = arg.strip.split(/[ \/]+/, -1)
    if vals.size != 2
      raise ArgumentError, "strange commission: #{arg}"
    end

    commission = Commission::Rule.new({
      :carrier => @carrier,
      :agent => vals[0],
      :subagent => vals[1],
      :source => caller_address
    }.merge(opts).reverse_merge(carrier_default_opts).reverse_merge(default_opts))

    commission.correct!

    self.opts = {}
    book.register commission
  end

  # заглушка для example который _не должны_ найти комиссию
  def no_commission(reason=true)
    # opts здесь по идее содержит только examples
    commission = Commission::Rule.new({
      :carrier => @carrier,
      :source => caller_address,
      :no_commission => reason
    }.merge(opts).reverse_merge(carrier_default_opts).reverse_merge(default_opts))

    # FIXME временно выключаю, потому что корректоры у нас пока работают только с числами
    # а их тут нет.
    # commission.correct!

    self.opts = {}
    book.register commission
  end

  # параметры конкретных правил
  # задаются после carrier,
  # но перед commission/no_commission
  #############################

  # выключает правило
  def disabled reason=true
    opts[:disabled] = reason
  end

  def not_implemented value=true
    opts[:not_implemented] = value
  end

  # правило интерлайна
  def interline *values
    opts[:interline] = values
  end

  # строчки из агентского договора (FM, комиссии, указываемые в бронировании)
  def agent line
    opts[:agent_comments] ||= ""
    opts[:agent_comments] += line + "\n"
  end

  # строчки из субагентского договора (маржа, которую мы оставим себе от fare)
  def subagent line
    opts[:subagent_comments] ||= ""
    opts[:subagent_comments] += line + "\n"
  end

  # tkt designator, используется при выписке в downtown
  def designator designator
    opts[:designator] = designator
  end

  # туркод, используется при выписке в downtown
  def tour_code tour_code
    opts[:tour_code] = tour_code
  end

  # внутренние авиалинии
  def domestic
    opts[:domestic] = true
  end

  # внешние авиалинии
  def international
    opts[:international] = true
  end

  # пока принимает уже готовый массив
  def routes routes
    opts[:routes] = routes
  end

  def subclasses *subclasses
    opts[:subclasses] = subclasses.join.upcase.gsub(' ', '').split('')
  end

  def classes *classes
    opts[:classes] = classes
  end

  def important!
    opts[:important] = true
  end

  def example str
    opts[:examples] ||= []
    opts[:examples] << [str, caller_address]
  end

  def check(check_text=nil, &block)
    # TODO включить после перехода
    # raise ArgumentError, "check block should be given as String" unless check_text
    block_text =
      "lambda do |recommendation|
        #{ check_text }
      end"
    # сдвиг (- 5) подобран руками для тестов. но в комиссиях срабатывает - 1. почему?
    block = eval(block_text, nil, caller_file, caller_line - 1) if check_text
    opts[:check] = check_text || '# COMPILED'
    opts[:check_proc] = block
  end

  def expr_date date
    opts[:expr_date] = date.to_date
  end

  def strt_date date
    opts[:strt_date] = date.to_date
  end

  # дополнительные опции, пока без обработки
  def system value
    opts[:system] = value
  end

  def ticketing_method value
    opts[:ticketing_method] = value
  end

  def consolidator value
    opts[:consolidator] = value
  end

  def blanks value
    opts[:blanks] = value
  end

  def discount value
    opts[:discount] = value
  end

  def our_markup value
    opts[:our_markup] = value
  end


  private

  def caller_address level=1
    caller[level] =~ /:(\d+)/
    $1 || 'unknown'
  end

  def caller_file level=1
    caller[level].split(':')[0]
  end

  def caller_line level=1
    caller[level].split(':')[1].to_i
  end

end
