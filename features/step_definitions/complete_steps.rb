RUSSIAN_MAPPING = {'имя' => :name, 'тип' => :type, /синонимы?|IATA/u => :aliases, 'заменит' => :insert, 'начало' => :start, 'конец' => :end, 'подсветит' => :hl }

Допустим /^в словаре есть:$/ do |table|
  RUSSIAN_MAPPING.each do |k,v|
    # UGLY - почему нельзя мэпить без эксепшнов?
    table.map_headers!( k => v ) rescue nil
  end
  @completer = Completer.new(table.hashes)
end

Если /^я ввел "([^\"]*)"$/ do |line|
  @line = line.mb_chars
  # эмуляция курсора
  if @pos = @line.index("|")
    @line = @line.sub("|", '')
  end
  @result = @completer.complete(@line, @pos)
end

То /^мне предложит "([^\"]*)"$/ do |word|
  @result.size.should == 1
  @result[0][:insert].should == word
end

То /^заменит "([^\"]*)"$/ do |word|
  @line[ @result[0][:start] ... @result[0][:end] ].to_s.should == word
end

То /^мне предложит:$/ do |table|
  RUSSIAN_MAPPING.each do |k,v|
    # UGLY - почему нельзя мэпить без эксепшнов?
    table.map_headers!( k => v ) rescue nil
  end

  table.diff!(@result)
end
