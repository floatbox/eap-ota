# encoding: utf-8
# перекрываем тайпусовские построители диапазонов
require 'typus/orm/active_record/search_override'

ActiveRecord::Base.extend Typus::Orm::ActiveRecord::SearchOverride
