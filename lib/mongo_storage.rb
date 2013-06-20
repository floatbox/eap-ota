# encoding: utf-8

class MongoStorage

class << self

  def collection
    Mongoid.default_session['storage']
  end

  def global_namespace
    'global'
  end

  def document_key(key, options)
    {:_id => namespaced_key(key, options)}
  end

  def expanded_key(key)
    case key
    when Array
      if key.size > 1
        key = key.collect{|element| expanded_key(element)}
      else
        key = key.first
      end
    when Hash
      key = key.sort_by { |k,_| k.to_s }.collect{|k,v| "#{k}=#{v}"}
    end

    key.to_param
  end

  def namespaced_key(key, options)
    key = expanded_key(key)
    namespace = options[:namespace] if options
    prefix = namespace ? namespace : global_namespace
    key = "#{prefix}:#{key}" if prefix
    key
  end

  def write(key, value, options = nil)
    options = {} unless options
    key = document_key(key, options)
    collection.find(key).upsert('$set' =>{:value => value, :set_at => Time.now})
  end
  
  def read_entry(key, options)
    key = document_key(key, options)
    collection.find(key).one
  end
  
  def read(key, options = nil)
    options = {} unless options
    entry = read_entry(key, options)
    entry["value"]
  end

  def set_at(key, options = nil)
    options = {} unless options
    entry = read_entry(key, options)
    entry["set_at"]
  end

  def exist?(key, options = nil)
    options = {} unless options
    entry = read_entry(key, options)
    entry ? true : false
  end

  def delete(key, options = nil)
    options = {} unless options
    key = document_key(key, options)
    collection.find(key).remove
  end
end

end
