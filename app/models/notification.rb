# encoding: utf-8
class Notification < ActiveRecord::Base

  belongs_to :order
  belongs_to :typus_user

  validates :destination, :presence => true

  before_validation :set_order_data
  after_create :set_order_email_status

  scope :email_queue, where(
    :method => 'email',
    :status => '')

  scope :reminder_queue, where('activate_from = ?', 2.days.since.to_date )\
    .where(
    :method => 'email',
    :status => '')

  alias_attribute :email, :destination

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
    update_attribute(:status, 'error')
    puts "Reminder pnr #{pnr_number} to #{destination} ERROR on #{Time.now}"
    raise
  end

  def self.process_queued_emails!
    counter = 0
    while (to_send = Notification.email_queue.first) && counter < 1
      to_send.send_email
      counter += 1
    end
    rescue
      HoptoadNotifier.notify($!) rescue Rails.logger.error("  can't notify hoptoad #{$!.class}: #{$!.message}")
  end

end