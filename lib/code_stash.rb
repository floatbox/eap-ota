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

  # добавляет метод SomeClass[code], который кэширует записи в текущем thread/request
  # ActiveRecord's query cache нааамного медленнее
  delegate :[], :to => :code_stash

  # @returns инстанс объекта по коду, если он есть
  # @returns nil если объект в базе отсутствует
  # @returns nil если code.nil?
  def fetch_by_code(code)
    raise "please,define method #{self}.fetch_by_code"
    # sample implementation:
    # return unless code
    # find_by_iata(code) || find_by_iata_ru(code)
  end

  def code_stash
    CodeStash.stash[name.to_s] ||= Hash.new do |hash, code|
      unless code.nil?
        data = fetch_by_code(code)
        if data
          hash[code] = data
          data
        else
          CodeStash.logger.info "#{name} #{code} #{Time.now.strftime("%H:%M %d.%m.%Y")}"
          raise NotFound, "Couldn't find #{name} with code '#{code}'"
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

