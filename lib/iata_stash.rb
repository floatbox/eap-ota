# encoding: utf-8
module IataStash
  # добавляет метод SomeClass[iata], который кэширует записи в текущем thread/request
  # ActiveRecord's query cache нааамного медленнее
  delegate :[], :to => :iata_stash

  def iata_stash
    @iata_cache ||= {}
    @iata_cache["#{name}_stash"] ||= Hash.new do |hash, iata|
      return if iata.nil?
      data = find_by_iata_ru(iata) if iata.match(/[А-Я]/u) && respond_to?(:find_by_iata_ru)
      hash[iata] = data || find_or_initialize_by_iata(iata)
    end
  end
end
