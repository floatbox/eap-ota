module IataStash
  # добавляет метод SomeClass[iata], который кэширует записи в текущем thread/request
  # ActiveRecord's query cache нааамного медленнее
  delegate :[], :to => :iata_stash

  def iata_stash
    @iata_cache ||= {}
    @iata_cache["#{name}_stash"] ||= Hash.new do |hash, iata|
      hash[iata] = find_or_initialize_by_iata(iata)
    end
  end
end
