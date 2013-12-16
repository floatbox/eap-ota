class PaymentCustomFields
  include KeyValueInit
  attr_accessor :ip, :first_name, :last_name, :phone, :email,
                :date, :points, :segments, :description, :pnr_number,
                :nationalities

  def order= order
    return unless order
    self.pnr_number = order.pnr_number
    self.date = order.departure_date
    self.email = cleanup_email(order.email)
    self.phone = order.phone.try(:gsub, /\D/, '')
    self.description = order.description.presence
  end

  def card= card
    return unless card
    self.first_name = card.first_name
    self.last_name = card.last_name
  end

  def order_form= order_form
    return unless order_form
    self.flights = order_form.recommendation.journey.flights
    self.email = cleanup_email(order_form.email)
    self.phone = order_form.phone.try(:gsub, /\D/, '')
    self.first_name = order_form.people.first.first_name
    self.last_name = order_form.people.first.last_name
    self.nationalities = order_form.people.map(&:nationality).map(&:alpha2)
  end

  def flights= flights
    return unless flights
    self.date = flights.first.dept_date
    self.points = []
    flights.every.departure_iata.zip( flights.every.arrival_iata ).flatten.each do |iata|
      points << iata unless iata == points.last
    end
  end

  def segments
    points.size - 1 unless points.blank?
  end

  def combined_name
    "#{first_name} #{last_name}" if first_name
  end

  private

  # платежные системы нервно реагируют на двойные емейлы в заказах
  def cleanup_email(email)
    if email.present?
      email.split(',').first.strip
    end
  end
end
