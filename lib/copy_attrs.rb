module CopyAttrs
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
end
