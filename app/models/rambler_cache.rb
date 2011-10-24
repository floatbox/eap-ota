class RamblerCache
  include Mongoid::Document
  field :data, :type => Array
  belongs_to :pricer_form
end
