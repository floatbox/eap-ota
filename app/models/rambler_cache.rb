class RamblerCache
  include Mongoid::Document
  include Mongoid::Timestamps
  field :data, :type => Array
  belongs_to :pricer_form
end
