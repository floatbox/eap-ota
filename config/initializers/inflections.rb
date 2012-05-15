# encoding: utf-8
# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format
# (all these examples are active by default):
ActiveSupport::Inflector.inflections do |inflect|
# TODO попробовать включить, должно повлиять на классы типа PNRMailer
#   inflect.acronym 'PNR'
#
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
    inflect.plural(/^Заказ$/i, 'Заказы')
    inflect.plural(/^Билет$/i,  'Билеты' )
    inflect.plural(/^Комментарий к заказу$/i, 'Комментарии к заказу' )
    inflect.plural(/^Платеж$/i,  'Платежи' )
    inflect.plural(/^Карта, платеж$/i,  'Карта, платежи' )
    inflect.plural(/^Наличные, платеж$/i,  'Наличные, платежи' )
    inflect.plural(/^Карта, возврат$/i,  'Карта, возвраты' )
    inflect.plural(/^Наличные, возврат$/i,  'Наличные, возвраты' )

    inflect.plural(/^Подборка рейсов$/i,  'Подборки рейсов' )
    inflect.plural(/^Подписка$/i,  'Подписки' )
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
    inflect.plural(/^Оповещение$/i,  'Оповещения' )
    inflect.plural(/^Партнер$/i,  'Партнеры' )
end

