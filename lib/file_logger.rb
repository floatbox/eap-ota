module  FileLogger

  def debug_dir= dir
    @@debug_dir = dir
  end

  def debug_dir
    defined?(@@debug_dir) ? @@debug_dir : 'log/xmls/'
  end

  def save_xml(prefix, xml)
    path = Rails.root + "log/xmls/#{prefix}_#{Time.now.strftime('%y%m%d-%H%M%S')}.xml"
    File.open(path, 'w') {|f| f.write(xml) }
  end

  def read_xml(prefix)
    mask = Rails.root + debug_dir + "#{prefix}_*.xml"
    path = Dir[mask].max_by {|f| File.mtime(f) }
    raise "no #{prefix}*.xml found" unless path
    File.read(path)
  end
end

