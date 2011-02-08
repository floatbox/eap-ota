# encoding: utf-8
class Cache
  # Rails.cache.load теперь возвращает frozen объекты
  # временно обходим это

  def self.filename_for(type, key)
    key.gsub!(/[^0-9a-zA-Z]/, '')
    Rails.root + 'tmp/cache' + "#{type}#{key}.cache"
  end

  def self.read(type, key)
    Marshal.load(File.read(filename_for(type, key)))
  end

  def self.write(type, key, data)
    open(filename_for(type, key), 'w') do |f|
       Marshal.dump(data, f)
    end
  end
end
