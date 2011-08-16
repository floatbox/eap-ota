module Typus
  module Orm
    module ActiveRecord
      module Search

        def build_datetime_conditions(key, value)
          tomorrow = value.to_date.tomorrow

          interval = value.to_date..tomorrow

          ["#{table_name}.#{key} BETWEEN ? AND ?", interval.first.to_s(:db), interval.last.to_s(:db)]
        end

      end
    end
  end
end
