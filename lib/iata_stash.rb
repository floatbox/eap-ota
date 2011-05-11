# encoding: utf-8
module IataStash

  class NotFound < ActiveRecord::RecordNotFound
    def initialize(iata)
      @message = "#{iata} not found"
    end
  end

  # добавляет метод SomeClass[iata], который кэширует записи в текущем thread/request
  # ActiveRecord's query cache нааамного медленнее
  delegate :[], :to => :iata_stash

  def iata_stash
    @iata_cache ||= {}
    @iata_cache["#{name}_stash"] ||= Hash.new do |hash, iata|
      unless iata.nil?
        data = find_by_iata_ru(iata) if iata.match(/[А-Я]/u)
        hash[iata] = data || find_by_iata(iata) || new(:iata => iata, :iata_ru => iata)
      end
    end
  end
end
