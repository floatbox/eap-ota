# encoding: utf-8

class Notification < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::TextHelper
  belongs_to :order
  belongs_to :typus_user

  #validates :destination, :presence => true
  #before_validation :set_order_data
  before_create :set_order_data
  after_create :delayed_send

  scope :email_queue, where(
    :method => 'email',
    :status => '')

  scope :reminder_queue, where('activate_from = ?', 2.days.since.to_date )\
    .where(
    :method => 'email',
    :status => '')

  alias_attribute :email, :destination

  def self.statuses; ["sent", "error", "delayed"] end
  def self.formats; ["order", "booking", "ticket"] end
  def self.langs; ["EN"] end

  # создание разных типов нотификаций
  # дефолтный нотис при создании ордера
  def create_delayed_notice delay=10
    self.status = 'delayed'
    if save
      order.queued_email!
      self.delay(queue: 'notification', run_at: delay.minutes.from_now, priority: 2).send_notice
    end
  end

  def set_order_data
    self.pnr_number = order.pnr_number
    self.destination = order.email
  end

  def delayed_send
    order.queued_email!
    self.delay(queue: 'notification', run_at: 1.minutes.from_now, priority: 2).send_notice if status.blank?
  end

  def retry_later delay=2
    puts "Email pnr #{pnr_number} to #{destination} RETRY after #{delay} minutes"
    self.delay(queue: 'notification', run_at: delay.minutes.from_now, priority: 2).send_notice
  end

  def prepare_notice
    if format.blank?
      self.format = order.send_notice_as
    end

    eng = true unless lang.blank?
    if subject.blank?
      case format
        when 'ticket'
          self.subject = eng ? "Your E-ticket [#{pnr_number}]" : "Ваш электронный билет [#{pnr_number}]" 
        when 'order'
          self.subject = eng ? "Your Order [#{pnr_number}]" : "Ваш заказ [#{pnr_number}]"
        when 'booking'
          self.subject = eng ? "Your Booking [#{pnr_number}]" : "Ваше бронирование [#{pnr_number}]"
      end
    end
    save
  end

  def send_notice
    if order.processing?
      logger.info 'Notification: retry sending later'
      retry_later
      return
    end

    I18n.locale = :ru
    prepare_notice
    logger.info 'Notification: sending email'
    NotifierMailer.notice(self).deliver
    update_attributes({:status => 'sent', 'sent_at' => Time.now})
    order.update_email_status(format + '_sent')
    puts "Email pnr #{pnr_number} to #{destination} SENT on #{Time.now}"
    rescue
      reload
      update_attribute(:status, 'error')
      puts "Email pnr #{pnr_number} to #{destination} ERROR on #{Time.now}"
    raise
  end

  def create_visa_notice
    self.attach_pnr = true
    self.subject = 'Информация о визе для вашего авиабилета'
    self.format = 'ticket'
    self.comment = CustomTemplate.new.render(:template => "notifications/visa_notice")
    save
  end

  def set_order_data
    self.pnr_number = order.pnr_number
    self.destination = order.email
  end

  def send_email
    logger.info 'Notification: sending email'
    PNRMailer.notice(self).deliver
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
    PNRMailer.notice(self).deliver
    update_attribute(:status, 'sent')
    puts "Reminder pnr #{pnr_number} to #{destination} SENT on #{Time.now}"
    rescue
      reload
      update_attribute(:status, 'error')
      puts "Reminder pnr #{pnr_number} to #{destination} ERROR on #{Time.now}"
    raise
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
