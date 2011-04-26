class Ticket < ActiveRecord::Base
  belongs_to :order
  delegate :source, :commission_carrier, :description, :to => 'order'

end

