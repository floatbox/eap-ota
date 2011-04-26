class Ticket < ActiveRecord::Base
  belongs_to :order
end

