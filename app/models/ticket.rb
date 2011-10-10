class Ticket < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  include CopyAttrs
  has_paper_trail
  belongs_to :order
  belongs_to :parent, :class_name => 'Ticket'
  has_one :refund, :class_name => 'Ticket', :foreign_key => 'parent_id'
  delegate :source, :commission_carrier, :pnr_number, :need_attention, :paid_by, :commission_carrier, :to => :order, :allow_nil => true

  scope :uncomplete, where(:ticketed_date => nil)

  before_create :set_refund_data, :if => lambda {kind == "refund"}
  validate :check_uniqueness_of_refund
  validates_presence_of :comment, :if => lambda {kind == "refund"}

  # FIXME сделать перечисление прямо из базы, через uniq
  def self.office_ids
    ['MOWR2233B', 'MOWR228FA', 'MOWR2219U']
  end

  def self.validators
    ['92223412', '92228065']
  end

  def self.sources
    ['amadeus', 'sirena']
  end

  def self.statuses
    ['ticketed', 'voided', 'pending']
  end

  def check_uniqueness_of_refund
    errors.add :refund, 'для данного билета уже существует' if kind == 'refund' && new_record? && Ticket.where(:parent_id => parent.id).count > 0
  end

  def set_refund_data
    copy_attrs parent, self,
      :validator,
      :office_id,
      :first_name,
      :last_name,
      :passport,
      :pnr_number,
      :order,
      :code,
      :number,
      :source
  end

  def ticket_date
    created_at.strftime('%d.%m.%Y') if created_at
  end

  def number_with_code
    "#{code}-#{number}" if number.present?
  end

  # номер первого билета для conjunction
  def first_number
    number.sub /-.*/, '' if number.present?
  end

  def refund_url
    if kind == 'ticket' && refund.blank?
      "<a href='/admin/tickets/new_refund?_popup=true&&resource[kind]=refund&resource[parent_id]=#{id}' class='iframe'>Add refund</a>".html_safe
    end
  end

  def first_number_with_code
    "#{code}-#{first_number}" if number.present?
  end

  def name
    "#{last_name} #{first_name}"
  end

  def carrier
    validating_carrier || commission_carrier
  end

  def price_total
    price_fare + price_tax
  end

  def price_transfer
    price_fare + price_tax + price_consolidator_markup - price_share
  end

  def price_refund
    if kind == 'refund'
      -(price_tax + price_fare + price_penalty)
    else
      0
    end
  end

  # для тайпуса
  def description
    if kind == 'ticket'
      (
      "Билет  № #{number_with_code} <br>" +
        if self.refund
          "есть #{!refund.processed ? 'неподтвержденный клиентом' : ''} возврат "
        else
          "<a href='/admin/tickets/new_refund?_popup=true&&resource[kind]=refund&resource[parent_id]=#{id}' class='iframe'>Добавить возврат</a>"
        end

      ).html_safe
    elsif kind == 'refund'
      (
      "Возврат для билета № #{number_with_code} <br>" +
      "Сумма к возварату: #{price_refund} рублей"
      ).html_safe
    end
  end

  #FIXME это костыль, работает не всегда, нужно сделать нормально
  def price_with_payment_commission
    k = (price_tax + price_fare).to_f / (order.price_fare + order.price_tax)
    order.price_with_payment_commission * k
  end

  def price_tax_and_markup_and_payment
    price_with_payment_commission - price_fare
  end

  def recalculate_commissions
    if commission_subagent
      self.price_share = commission_subagent['%'] ? (price_fare * commission_subagent[0...-1].to_f / 100) : commission_subagent.to_f
      self.price_consolidator_markup = if price_share > 5
          0
        elsif %W( LH LX KL AF OS ).include? commission_carrier
          price_fare * 0.01
        else
          price_fare * 0.02
        end
    end
    true
  end
  before_save :recalculate_commissions

  # для админки
  def to_label
    "#{source} #{number} #{route} #{updated_at}"
  end

  def itinerary_receipt
    if order && !new_record?
      url = show_order_for_ticket_path(order.pnr_number, self)
      "<a href=#{url}>билет</a>".html_safe
    end
  end

  def raw # FIXME в стратегию
    Strategy.new(:source => 'amadeus', :ticket => self).raw_ticket
  rescue => e
    e.message
  end
end
