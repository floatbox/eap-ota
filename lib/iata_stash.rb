module IataStash
  # добавляет метод SomeClass[iata], который кэширует записи в текущем thread/request
  # ActiveRecord's query cache нааамного медленнее
  delegate :[], :to => :stash

  def stash
    Thread.current["#{name}_stash"] ||= Hash.new do |hash, iata|
      hash[iata] = find_or_initialize_by_iata(iata)
    end
  end
end
