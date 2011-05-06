class Ticket < ActiveRecord::Base
  belongs_to :order
  delegate :source, :commission_carrier, :description, :pnr_number, :need_attention, :to => 'order'

  def ticket_date
    created_at.strftime('%d.%m.%Y')
  end

  def price_total
    price_fare + price_tax
  end

  def price_transfer
    price_fare + price_tax + price_consolidator_markup - price_share
  end

end

