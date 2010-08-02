module IataStash
  # добавляет метод SomeClass[iata], который кэширует записи в текущем thread/request
  # ActiveRecord's query cache нааамного медленнее
  def [](code)
    stash[code] ||= find_by_iata(code)
  end

  def stash
    Thread.current["#{name}_stash"] ||= Hash.new  # {|iata| new(:iata => iata)}
  end
end
