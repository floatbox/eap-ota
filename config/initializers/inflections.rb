# encoding: utf-8
# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format
# (all these examples are active by default):
ActiveSupport::Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
    inflect.plural(/^Заказ$/i, 'Заказы')
    inflect.plural(/^Билет$/i,  'Билеты' )
    inflect.plural(/^Комментарий к заказу$/i, 'Комментарии к заказу' )
    inflect.plural(/^Платеж$/i,  'Платежи' )
    inflect.plural(/^Подборка рейсов$/i,  'Подборки рейсов' )
    inflect.plural(/^Направление$/i,  'Направления' )
    inflect.plural(/^Горячее предложение$/i,  'Горячие предложения' )
    inflect.plural(/^Геотаг$/i,  'Геотаги' )
    inflect.plural(/^Аэропорт$/i,  'Аэропорты' )
    inflect.plural(/^Город$/i,  'Города' )
    inflect.plural(/^Регион$/i,  'Регионы' )
    inflect.plural(/^Страна$/i,  'Страны' )
    inflect.plural(/^Альянс авиакомпаний$/i,  'Альянсы авиакомпаний' )
    inflect.plural(/^Глобальная дистрибьюторская система$/i,  'Глобальные дистрибьюторские системы' )
    inflect.plural(/^Перевозчик$/i,  'Перевозчики' )
    inflect.plural(/^Консолидатор$/i,  'Консолидаторы' )
    inflect.plural(/^Самолет$/i,  'Самолеты' )
    inflect.plural(/^Пользователь Typus$/i,  'Пользователи Typus' )

end

