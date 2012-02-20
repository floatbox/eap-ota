# encoding: utf-8
module CustomCSV
  def generate_csv
    fields = @resource.typus_fields_for(:csv)
    filename = Rails.root.join("tmp", "export-#{@resource.to_resource}-#{Time.zone.now.to_s(:number)}.csv")
    options = { :conditions => @conditions, :batch_size => 1000 }
    ::CSV.open(filename, 'w:windows-1251', :col_sep => ';') do |csv|
      csv << fields.keys.map { |k| @resource.human_attribute_name(k) }
      @resource.find_in_batches(options) do |records|
        records.each do |record|
          csv << fields.map do |key, value|
            case value
            when :transversal
              a, b = key.split(".")
              record.send(a).send(b)
            when :belongs_to
              record.send(key).to_label
            else
              res = record.send(key)
              if res.is_a? BigDecimal
                res.to_s.sub('.', ',') + ' р.'
              else
                res
              end
            end
          end
        end
      end
    end

    send_file filename
  end
end

