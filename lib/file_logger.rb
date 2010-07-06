module  FileLogger
  def self.save(prefix, xml)
    path = Rails.root + "log/xmls/#{prefix}_#{Time.now.strftime('%y%m%d-%H%M%S')}.xml"
    File.open(path, 'w') {|f| f.write(xml) }
  end

  def self.read_latest(prefix)
    mask = Rails.root + "log/xmls/#{prefix}_*.xml"
    path = Dir[mask].max_by {|f| File.mtime(f) }
    raise "no #{prefix}*.xml found" unless path
    File.read(path)
  end
end
