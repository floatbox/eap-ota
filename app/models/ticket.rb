class Ticket < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  belongs_to :order
  delegate :source, :commission_carrier, :pnr_number, :need_attention, :paid_by, :commission_carrier, :to => :order, :allow_nil => true

  def ticket_date
    created_at.strftime('%d.%m.%Y') if created_at
  end

  def number_with_code
    "#{code}-#{number}" if number.present?
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
end

