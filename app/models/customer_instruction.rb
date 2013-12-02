class CustomerInstruction < ActiveRecord::Base
  belongs_to :customer

  def self.statuses; ['sent', 'error', 'delayed'] end

  def sent_status
    if status == 'error'
      str_status = '<span style="color:red">' + status + '</span>'
    else
      str_status = status
    end
    str_status += ' to ' + email
    str_reason = '<br><br><span style="color:red">' + reason + '</span>' if reason
    (str_status + str_reason.to_s).html_safe
  end

  def error_reason
      ('<strong>' + email.to_s + '</strong> <br><br> ' + reason.to_s).html_safe if reason
  end

  def load_sendgrid_status
    sc = SendgridClient.new
    request_params = {:email => email, :date_start => created_at}
    self.reason = nil
    blocks = sc.blocks(request_params)
    unless blocks.blank?
      self.reason = 'Block: ' + blocks.first["reason"]
    end

    bounces = sc.bounces(request_params) unless reason
    unless bounces.blank?
      self.reason = 'Bounce ' + bounces.first["reason"]
    end

    invalidemails = sc.invalidemails(request_params) unless reason
    unless invalidemails.blank?
      self.reason = 'Invalidemail: ' + invalidemails.first["reason"]
    end

    if reason
      self.status = 'error'
      save
    end
  end

end
