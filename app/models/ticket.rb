class Ticket < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  belongs_to :order
  delegate :source, :commission_carrier, :pnr_number, :need_attention, :to => 'order'

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

  # для админки
  def to_label
    "#{source} #{number} #{route} #{updated_at}"
  end

  def itinerary_receipt
    url = show_order_for_ticket_path(order.pnr_number, self)
    "<a href=#{url}>билет</a>".html_safe
  end
end

