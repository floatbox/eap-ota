class Preset < ActiveRecord::Base

  serialize :query

  def to_param
    name
  end

end
