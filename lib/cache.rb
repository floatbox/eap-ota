# encoding: utf-8
class Cache
  # Rails.cache.load теперь возвращает frozen объекты
  # временно обходим это

  def self.filename_for(type, key)
    Rails.root + 'tmp/cache' + "#{type}#{key}.cache"
  end

  def self.read(type, key)
    Marshal.load(File.read(filename_for(type, key)))
  end

  def self.write(type, key, data)
    open(filename_for(type, key), 'w') do |f|
       f << Marshal.dump(data)
    end
  end
end
