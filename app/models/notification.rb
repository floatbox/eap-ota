# encoding: utf-8
class Notification < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::TextHelper
  belongs_to :order
  belongs_to :typus_user

  validates :destination, :presence => true

  before_validation :set_order_data

  scope :email_queue, where(
    :method => 'email',
    :status => '')

  scope :reminder_queue, where('activate_from = ?', 2.days.since.to_date )\
    .where(
    :method => 'email',
    :status => '')

  alias_attribute :email, :destination

  def self.statuses; ["sent", "error", "delayed"] end
  def self.formats; ["booking", "ticket"] end
  def self.langs; ["EN"] end

  def create_pnr
    self.attach_pnr = true
    save
    set_order_email_status
  end

  def create_visa_notice
    self.attach_pnr = false
    self.subject = 'уведомление о визовых данных'
    self.comment = 'уведомление о визовых данных'
    self.status = 'delayed'
    save
  end

  def set_order_data
    self.pnr_number = order.pnr_number
    self.destination = order.email
  end

  def set_order_email_status
    order.queued_email!
  end

  def send_email
    logger.info 'Notification: sending email'
    PnrMailer.notice(self).deliver
    update_attributes({:status => 'sent', 'sent_at' => Time.now})
    puts "Email pnr #{pnr_number} to #{destination} SENT on #{Time.now}"
    rescue
      reload
      update_attribute(:status, 'error')
      puts "Email pnr #{pnr_number} to #{destination} ERROR on #{Time.now}"
    raise
  end

  def send_reminder
    logger.info 'Notification: sending reminder'
    PnrMailer.notice(self).deliver
    update_attribute(:status, 'sent')
    puts "Reminder pnr #{pnr_number} to #{destination} SENT on #{Time.now}"
    rescue
      reload
      update_attribute(:status, 'error')
      puts "Reminder pnr #{pnr_number} to #{destination} ERROR on #{Time.now}"
    raise
  end

  # а оно сейчас еще используется? по одному письму в пять минут?
  # FIXME вынесите если больше не нужно
  def self.process_queued_emails!
    counter = 0
    while (to_send = Notification.email_queue.first) && counter < 50
      to_send.send_email
      counter += 1
    end
    rescue
      Airbrake.notify($!) rescue Rails.logger.error(" can't notify airbrake #{$!.class}: #{$!.message}")
  end

  def sent_status
    if status == 'sent'
      str = 'sent'
      str += ' to ' + destination
      str += '<br>at ' + sent_at.strftime('%d.%m.%y %H:%M') if sent_at
      str += '<br>' + sent_notice_link if rendered_message
      str.html_safe
    else
      status
    end
  end

  def sent_notice_link
    url = show_sent_notice_path(self)
    "<a href=#{url} target=\"_blank\">&rarr;письмо</a>"
  end

end
