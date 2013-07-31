# encoding: utf-8
module CodeStash

  class NotFound < RuntimeError
  end

  def self.logger
    @@logger ||= Logger.new(Rails.root + 'log/missed_iatas.log')
  end

  def self.stash
    @@stash ||= {}
  end

  def self.clear
    stash.clear
  end

  # добавляет метод SomeClass[iata], который кэширует записи в текущем thread/request
  # ActiveRecord's query cache нааамного медленнее
  delegate :[], :to => :code_stash

  def code_stash
    CodeStash.stash[name.to_s] ||= Hash.new do |hash, iata|
      unless iata.nil?
        data = find_by_iata(iata) || find_by_iata_ru(iata)
        if data
          hash[iata] = data
          # hash[data.iata] = data if data.iata.present?
          # hash[data.iata_ru] = data if data.iata_ru.present?
          data
        else
          CodeStash.logger.info "#{name} #{iata} #{Time.now.strftime("%H:%M %d.%m.%Y")}"
          raise NotFound, "Couldn't find #{name} with IATA '#{iata}'"
        end
      end
    end
  end

  class Middleware
    def initialize(app)
      @app = app
    end

    # очищает CodeStash после каждого реквеста
    def call(env)
      @app.call(env)
    ensure
      ::CodeStash.clear
    end
  end
end

