# encoding: utf-8

module AssociationErrorJsonifier
  # улучшалка для errors.to_json
  # чинит поведение для nested ошибок валидации,
  # добавляет метод errors_to_json на все ActiveRecord объекты
  #
  # манки-патч на ActiveModel::Errors#to_json, был бы еще козырнее,
  # но оттуда нет доступа к association_cache
  #
  # меняет дефолтное сломанное поведение:
  # {
  #   "person.first_name": ["<error message 1>", "<error message 2>"],
  #   "my_cool_field": ["error message"]
  # }
  #
  # на такое:
  # {
  #   "person[0].first_name": ["<error message 1>"],
  #   "person[1].first_name": ["<error message 2>"],
  #   "my_cool_field": ["error message"]
  # }
  #

  extend ActiveSupport::Concern

  def errors_to_json(options=nil)
    # выбираем ошибки валидации без ошибок валидации ассоциаций
    self_errors = Hash.new(*errors.select { |field, _| field =~ /\./ })

    # добавляем ошибки ассоциаций структурированно
    association_errors = {}
    association_cache.each do |assoc, _|
      association_cache[assoc].target.collect(&:errors).collect(&:messages).each_with_index do |target_errors, index|
        target_errors.each do |field, messages|
          association_errors["#{assoc}.#{index}.#{field}"] = messages
        end
      end
    end

    all_errors = self_errors.merge(association_errors)

    ActiveSupport::JSON.encode(all_errors, options)
  end
end

# раскомментить для появления метода на все AR-объектах
#class ActiveRecord::Base
  #include AssociationErrorJsonifier
#end

