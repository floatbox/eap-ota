# encoding: utf-8
module CustomCSV
  require 'iconv'
  def generate_csv
    cp1251 = Iconv.new("windows-1251", 'utf-8')
    fields = @resource.typus_fields_for(:csv)
    filename = Rails.root.join("tmp", "export-#{@resource.to_resource}-#{Time.zone.now.to_s(:number)}.csv")
    options = { :conditions => @conditions, :batch_size => 1000 }
    ::CSV.open(filename, 'w', ';') do |csv|
      csv << fields.keys
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
                     if res.is_a? String
                       cp1251.iconv(res)
                     elsif res.is_a? BigDecimal
                       res.to_s.sub('.', ',')
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

