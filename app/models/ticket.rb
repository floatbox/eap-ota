class Ticket < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  has_paper_trail
  belongs_to :order
  delegate :source, :commission_carrier, :pnr_number, :need_attention, :paid_by, :commission_carrier, :to => :order, :allow_nil => true

  scope :uncomplete, where(:ticketed_date => nil)

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
    ['ticketed', 'voided']
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
    url = show_order_for_ticket_path(order.pnr_number, self)
    "<a href=#{url}>билет</a>".html_safe
  end

  def raw # FIXME в стратегию
    Strategy.new(:source => 'amadeus', :ticket => self).raw_ticket
  rescue => e
    e.message
  end
end
