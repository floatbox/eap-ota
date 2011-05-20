# encoding: utf-8
module IataStash

  class NotFound < RuntimeError
  end

  # добавляет метод SomeClass[iata], который кэширует записи в текущем thread/request
  # ActiveRecord's query cache нааамного медленнее
  delegate :[], :to => :iata_stash

  def iata_stash
    @iata_cache ||= {}
    @iata_cache["#{name}_stash"] ||= Hash.new do |hash, iata|
      unless iata.nil?
        data = find_by_iata(iata) || find_by_iata_ru(iata)
        if data
          hash[data.iata] = data if data.iata.present?
          hash[data.iata_ru] = data if data.iata_ru.present?
          data
        else
          File.open(Rails.root + 'log/missed_iatas.log', 'a') {|f|
            f.write(name + ' ' + iata + ' ' + Time.now.strftime("%H:%M %d.%m.%Y") + "\n")
          }
          raise NotFound, "Couldn't find #{name} with IATA '#{iata}'"
        end
      end
    end
  end
end

