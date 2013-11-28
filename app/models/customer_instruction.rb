class CustomerInstruction < ActiveRecord::Base
  belongs_to :customer

  def self.statuses; ["sent", "error", "delayed"] end

  def sent_status
      (status + ' to ' + email).html_safe
  end

end
