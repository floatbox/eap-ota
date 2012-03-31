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
  def nested(path, default_value=nil)
    path.split('.').inject(self) do |hash, partial_key|
      unless hash.respond_to?(:has_key?) && hash.has_key?(partial_key)
        return default_value
      end
      hash[partial_key]
    end
  end
end
Hash.send :include, FetchNested
