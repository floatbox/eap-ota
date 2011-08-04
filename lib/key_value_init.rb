# encoding: utf-8
module KeyValueInit
  # common idiom. tired of typing it everywhere
  def initialize attrs={}
    update_attributes attrs
  end

  def update_attributes attrs
    attrs.each do |attr, value|
      send "#{attr}=", value
    end
  end

  alias attributes= update_attributes
end
