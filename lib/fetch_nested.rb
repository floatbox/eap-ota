# encoding: utf-8
module FetchNested
  # Fetches deep nested hash value by its dot-separated path
  #
  # hash = {'foo' => {'bar' => {'baz' => 3}}}
  # hash.nested('foo.bar.baz')
  # => 3
  # hash.nested('foo.key')
  # => nil
  # hash.nested('foo.key', 5)
  # => 5
  #
  # you can also use [] notation
  # hash.nested
  # => #<FetchNested::Proxy @hash={}>
  # hash.nested['foo.bar']
  # => {'baz' => 3}
  def nested(path=nil, default_value=nil)
    return FetchNested::Proxy.new(self) if path.nil?
    path.split('.').inject(self) do |hash, partial_key|
      return default_value if !hash.is_a?(Hash) || !hash.has_key?(partial_key)
      hash[partial_key]
    end
  end

  def nested_assign(path, value)
    *route, target_key = path.split('.')
    hash = route.inject(self) do |hash, partial_key|
      hash[partial_key] = {} unless hash[partial_key].is_a?(Hash)
      hash[partial_key]
    end
    hash[target_key] = value
  end

  # hash.each_nested.to_a
  # => [["foo.bar", 3], ["test": "oink"]]
  # hash.each_nested do |combined_key, value|
  def each_nested(prefix=nil, &block)
    return enum_for(:each_nested) unless block
    each_pair do |key, value|
      name = prefix ? "#{prefix}.#{key}" : key.to_s
      case value
      when Hash
        value.each_nested(name, &block)
      else
        yield name, value
      end
    end
  end

  class Proxy
    def initialize(hash)
      @hash = hash
    end

    def [](*args)
      @hash.nested *args
    end

    def []=(*args)
      @hash.nested_assign *args
    end
  end

end
Hash.send :include, FetchNested
