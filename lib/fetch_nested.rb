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
    path.split('.').reduce(self) do |hash, partial_key|
      hash[partial_key] or return default_value
    end
  end
end
Hash.send :include, FetchNested
