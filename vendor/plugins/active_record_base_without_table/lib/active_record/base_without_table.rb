module ActiveRecord
  class BaseWithoutTable < Base
    self.abstract_class = true

    def create; errors.empty? end
    def update; errors.empty? end
    def new_record?; true end


    class << self
      def columns()
        @columns ||= []
      end

      def column(name, sql_type = nil, default = nil, null = true)
        columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
        reset_column_information
      end

      # Reset everything, except the column information
      def reset_column_information
        columns = @columns
        super
        @columns = columns
      end
    end
  end
end

