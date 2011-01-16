# encoding: utf-8
module  FileLogger

  def debug_dir= dir
    @@debug_dir = dir
  end

  def debug_dir
    defined?(@@debug_dir) ? @@debug_dir : 'log/xmls/'
  end

  def save_xml(prefix, xml)
    base_name = Time.now.strftime('%y%m%d-%H%M%S') + '.xml'
    path = Rails.root + debug_dir + "#{prefix}_#{base_name}"
    File.open(path, 'w') {|f| f.write(xml) }
    base_name
  end

  def read_latest_xml(prefix)
    mask = Rails.root + debug_dir + "#{prefix}_*.xml"
    path = Dir[mask].max_by {|f| File.mtime(f) }
    raise "no #{prefix}*.xml found" unless path
    File.read(path)
  end

  def read_each_xml(prefix)
    mask = Rails.root + debug_dir + "#{prefix}_*.xml"
    paths = Dir[mask]
    raise "no #{prefix}*.xml found" if paths.empty?
    paths.each do |p|
      yield(File.read(p), p)
    end
  end
end

