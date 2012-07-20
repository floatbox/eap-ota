# рыба для задания делейед джобу, когда Object#delay недостаточно

class SampleJob

  # при создании задачи объект задачи сериализуется в YAML и кладется в монгу/базу
  # поэтому лучше при инициализации в атрибуты класть pnr_number вместо Order-а целиком,
  # не передавать разные там Proc и Recommendation, и т.п.
  #
  def initialize(args={})
    #args.assert_valid_keys(:foo, :bar)

  end

  # самый главный метод. собственно здесь и делается работа.
  # если не бросил эксепшнов, считается успешно выполненным и убирается из очереди
  # остальные методы вообще можно не писать.
  #
  def perform
  end

  # метод может называться как угодно, используем для удобной постановки в очередь
  # с дефолтными # параметрами.
  # SampleJob.new(args).delay
  def delay(args={})
    Delayed::Job.enqueue(self, {
      # queue: 'messaging',
      # priority: 0,  # самый высокий приоритет, дефолтный
      # run_at: 15.minutes.from_now, # если надо отложить первый старт
    }.merge(args))
  end

  # как показывать задачу в логах
  # по дефолту - class.name
  #
  # def display_name
  # end

  # максимальное количество попыток
  # дефолт выставляется в config/initializers/delayed_job.rb
  #
  # def max_attempts
  # end

  # когда попытаться запуститься еще раз, в случае ошибки
  # дефолтная реализация
  #
  # def reschedule_at(now, attempts)
  #   now + (attempts**4) + 5 # seconds
  # end

  # вызывается перед сохранением в очередь. можно какие-то флаги поставить
  # не вызывается вообще, если Delayed::Worker.delay_jobs==false
  # (задачи выполняются синхронно)
  # объект job содержит в себе #attempts, #last_error и что-то еще.
  #
  # def enqueue(job)
  # end

  # вызывается перед perform. не знаю, в чем глубинный смысл
  #
  # def before(job)
  # end

  # вызывается после каждой попытки perform, после success или error,
  # вне зависимости от успешности
  #
  # def after(job)
  # end

  # вызывается, если perform не бросил эксепшнов
  #
  # def success(job)
  # end

  # вызывется, если perform (или success) бросили эксепшн
  #
  def error(job, exception)
    Airbrake.notify(exception)
  end

  # вызвается после исчерпания attempts, перед удалением задачи из очереди
  # можно, опять же, выставить какие-то флаги на обрабатываемом объекте
  #
  # def failure(job)
  # end

end
