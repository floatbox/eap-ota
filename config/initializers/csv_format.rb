# encoding: utf-8
require 'csv'

ActionController::Renderers.add :csv do |obj, options|
  filename = options[:filename] || 'data'
  str = obj.respond_to?(:to_csv) ? obj.to_csv : obj.to_s
  send_data str, :type => Mime::CSV,
    :disposition => "attachment; filename=#{filename}.csv"
end

class Array
  def to_csv
    if self.all?{|e| e.is_a? Hash}
      fields = self[0].keys
      return ::CSV.generate do |csv|
        csv << fields
        each do |hash|
          csv << fields.map do |key|
            hash[key]
          end
        end
      end
    end
    return
  end

end
