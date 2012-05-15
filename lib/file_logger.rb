# encoding: utf-8

# TODO переделать в класс, а то родительский класс
# захламляется методами
module  FileLogger

  def debug_dir= dir
    @@debug_dir = dir
  end

  def debug_ext= extension
    @@debug_ext = extension
  end

  def debug_dir
    defined?(@@debug_dir) ? @@debug_dir : 'log/files/'
  end

  def debug_ext
    defined?(@@debug_ext) ? @@debug_ext : 'xml'
  end

  # example: log/amadeus/2012-04-03/12h04m94s123.#{prefix}.xml"
  def log_file(prefix, content)
    path = Rails.root + debug_dir + Time.now.strftime("%Y-%m-%d/")
    base_name = prefix + '.' + Time.now.strftime("%H-%M-%S-%3N") + '.' + debug_ext
    name = path + base_name
    # FIXME возможно, это медленно. перехватывать эксепшн и ретраить?
    #FileUtils.makedirs(path)
    File.open!(name, 'w') {|f| f << content}
    name
  end

  def read_latest_log_file(prefix)
    path = log_file_paths(prefix).max_by {|f| File.mtime(f) }
    File.read(path)
  end

  def read_each_log_file(prefix)
    log_file_paths(prefix).each do |p|
      yield(File.read(p), p)
    end
  end

  def log_file_paths(prefix)
    mask = Rails.root + debug_dir + "*/#{prefix}.*.#{debug_ext}"
    paths = Dir[mask]
    raise "no #{prefix}* found" if paths.empty?
    paths
  end

end

