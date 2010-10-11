module KeyValueInit
  # common idiom. tired of typing it everywhere
  def initialize attrs={}
    attrs.each do |attr, value|
      send "#{attr}=", value
    end
  end
end
