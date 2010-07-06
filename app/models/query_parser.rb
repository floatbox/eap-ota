# maybe move to lib/
class QueryParser

  mattr_accessor :handlers

  def self.grok *regexen, &callback
    self.handlers ||= []
    self.handlers += regexen.collect {|r| [r, callback]}
  end
  #-------------------
  
  # считывалка пресетов
  Preset.all.each do |p|
    # FIXME переделать в регекс?
    grok p.name do |query|
      query.update p.query
    end
  end

  # пассажиры
  grok /вдв[оё]ем/ do |query|
    query.adults = 2
  end

  grok /втро[её]м/ do |query|
    query.adults = 3
  end

  grok /вчетвером/ do |query|
    query.adults = 4
  end

  grok /с реб[её]нком/ do |query|
    query.children = 1
  end

  # диапазоны
  grok /завтра/ do |query|
    query.date = {:date1 => [Date.tomorrow], :date2=>[Date.tomorrow + 6]}
  end

  grok /послезавтра/ do |query|
    query.date = {:date1 => [Date.tomorrow + 1], :date2=>[Date.tomorrow + 7]}
  end

  grok /на пару дней/ do |query|
    if query.date && d1 = query.date.date1.first
      query.date.date2 = [d1 + 1]
    end
  end

  grok /на неделю/ do |query|
    if query.date && d1 = query.date.date1.first
      query.date.date2 = [d1 + 6]
    end
  end

  grok /на выходные/ do |query|
    # пока только на следующие
    d1 = Date.today + (5 - Date.today.wday)
    d1 = d1 + 7 if d1 <= Date.today
    d2 = d1 + 2
    query.date = {:date1 => [d1], :date2 => [d2]}
    #self.ret = :rt
  end

  # TODO
  # бизнес-классом
  # на боинге

  # --------------

  def initialize query_obj
    @query = query_obj
  end

  attr_accessor :query

  def self.parse(query_obj, text)
    new(query_obj).parse(text)
  end

  def parse(text)
    QueryParser.handlers.each do |regex, block|
      if text[regex]
        block.call(query)
      end
    end
  end

  def self.known_words_regex
    # FIXME cache it? or forgive
    /\b(#{ handlers.every.first.join('|') })\b/
  end

end
