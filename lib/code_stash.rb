# encoding: utf-8
#
# Добавляет очищаемый in memory кэш для активрекордных и прочих справочников,
# адресуемых по произвольному коду.
# ActiveRecord's query cache нааамного медленнее. Плюс, экономит память
#
# @usage
#   class SomeModel
#     extend CodeStash
#
#     # required. Должен возвращать nil, если пока такого объекта нет.
#     def self.fetch_by_code(code)
#        find(code: code)
#     end
#
#     # optional. Если можно автоматически добавлять новые объекты, зная только их код.
#     def self.make_by_code(code)
#        create(code: code)
#     end
#
#     # optional. Если кодов у объекта несколько, можно вернуть их все,
#     # и объект займет слоты в хранилище по всем своим кодам, заранее.
#     def codes
#       [code, code2, code.upcase]
#     end
#   end
#
#   => SomeModel[code]
#
#   бросит CodeStash::NotFound, если объект не найдет и не может быть создан
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

  # добавляет метод SomeClass[code], который кэширует записи в текущем thread/request.
  # @raise CodeStash::NotFound если объект не найден.
  delegate :[], :to => :code_stash

  # @return объект по коду, если он есть
  # @return nil если объект в базе отсутствует
  def fetch_by_code(code)
    raise "please, define method #{self}.fetch_by_code"
    # sample implementation:
    # find_by_iata(code) || find_by_iata_ru(code)
  end

  # если класс позволяет создать новый объект имея только его код,
  # надо оверрайднуть этот метод, и вернуть этот объект.
  # @return nil, если объект создать нельзя
  def make_by_code(code)
    nil
  end

  def code_stash
    CodeStash.stash[name.to_s] ||= Hash.new do |hash, code|
      unless code.nil?
        object = fetch_by_code(code) || make_by_code(code)
        if object
          # вносим объект в стэш по запрошенному коду и по всем его остальным кодам,
          # если они есть
          codes = [code]
          codes << Array(object.codes).compact if object.respond_to?(:codes)
          codes.each {|c| hash[c] = object }
          object
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
      ::CodeStash.clear if Conf.performance.clear_code_stash
    end
  end
end

