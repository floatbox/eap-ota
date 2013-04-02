module CopyAttrs
  # копирует одноименные атрибуты из from в to
  def copy_attrs from, to, opts={}, *attrs
    unless opts.is_a? Hash
      attrs.unshift opts
      opts = {}
    end
    prefix = opts[:prefix].to_s + '_' if opts[:prefix]
    attrs.each do |attr|
      to.send("#{prefix}#{attr}=", from.send(attr))
    end
  end

  # суммирует атрибуты каждого элемента froms и копирует суммы в атрибуты to
  def sum_and_copy_attrs froms, to, opts={}, *attrs
    unless opts.is_a? Hash
      attrs.unshift opts
      opts = {}
    end
    prefix = opts[:prefix].to_s + '_' if opts[:prefix]
    attrs.each do |attr|
      to.send("#{prefix}#{attr}=", froms.map {|from| from.send(attr) }.sum)
    end
  end
end
