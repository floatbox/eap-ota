class CustomerInstruction < ActiveRecord::Base
  belongs_to :customer

  def self.statuses; ["sent", "error", "delayed"] end

  def sent_status
    if status == 'sent'
      str = 'sent'
      str += ' to ' + email
      str += '<br>at ' + created_at.strftime('%d.%m.%y %H:%M') if created_at
      str.html_safe
    else
      status
    end
  end

  def error_reason
      ('<strong>' + email.to_s + '</strong> <br><br> ' + reason.to_s).html_safe if reason
  end

  def load_sendgrid_status
    sc = SendgridClient.new
    blocks = sc.blocks(:email => email, :date_start => created_at).first
    self.reason = blocks["reason"] if blocks

    unless reason
      bounces = sc.bounces(:email => email, :date_start => created_at).first
      self.reason = bounces["reason"] if bounces
    end

    unless reason
      invalidemails = sc.invalidemails(:email => email, :date_start => created_at).first
      self.reason = invalidemails["reason"] if invalidemails
    end

    if reason
      self.status = 'error'
      save
    end
  end

end
