# encoding: utf-8

# "считыватель" для Commission::Book, старый синтаксис
class Commission::Reader

  attr_accessor :book

  # FIXME interline не клонируется с помощью .dup
  # в рельсах 4.0 будет .deep_dup
  READER_DEFAULTS = {
    interline: [:no],
    system: :amadeus,
    consolidator: 0,
    blanks: 0,
    discount: 0,
    our_markup: 0,
    agent: "",
    subagent:""
  }

  def initialize(book = Commission::Book.new)
    self.book = book
  end

  # выполняет определения в блоке и возвращает готовую "книгу"
  def define(&block)
    instance_eval(&block)
    book
  end

  # считывает определения из строки и возвращает готовую "книгу"
  def read(book_string)
    instance_eval(book_string)
    book
  end

  # считывает определения из файла (или каталога) и возвращает готовую "книгу"
  def read_file(filename)
    if test ?d, filename
      Dir["#{filename}/**/*.rb"].each do |file|
        read_file(file)
      end
    else
      instance_eval(File.read(filename), filename)
    end
    book
  end

  # Открывает страницу правил по конкретной авиакомпании/периоду времени
  # @param carrier [String] IATA код авиакомпании
  # @param page_opts [Hash]
  def carrier carrier, page_opts={}
    raise ArgumentError, "strange carrier: #{carrier}" unless carrier =~ /\A..\Z/
    @carrier = carrier
    page_opts[:start_date] &&= page_opts[:start_date].to_date
    @page = @book.create_page( page_opts.merge(carrier: carrier) )
  end

  # определяет правило в текущей странице.
  # @param number [Fixnum] номер правила. Пока только для удобства чтения.
  def rule number=nil, &block
    reader = Commission::Reader::Rule.new(@page)
    reader.define(number: number, source: caller_address, &block)
  end

  private

  def caller_address level=1
    caller[level] =~ /^(.*?:\d+)/
    # по каким-то причинам тут приходит US-ASCII
    # конвертирую для yaml
    ($1 || 'unknown').encode('UTF-8')
  end

end
