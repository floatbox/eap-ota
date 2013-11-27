class CustomerInstruction < ActiveRecord::Base
  belongs_to :customer

  def self.statuses; ["sent", "error", "delayed"] end
end
