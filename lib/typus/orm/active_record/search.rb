module Typus
  module Orm
    module ActiveRecord
      module Search

        def build_datetime_conditions(key, value)

          if value.include?('/') 
            firstdate, lastdate = value.split('/')
            interval = firstdate.to_date.beginning_of_day..lastdate.to_date.tomorrow.beginning_of_day
          else
            tomorrow = value.to_date.tomorrow.beginning_of_day
            interval = value.to_date.beginning_of_day..tomorrow
          end
          ["#{table_name}.#{key} BETWEEN ? AND ?", interval.first.to_s(:db), interval.last.to_s(:db)]
        end

      end
    end
  end
end
