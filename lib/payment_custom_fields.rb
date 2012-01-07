class PaymentCustomFields
  include KeyValueInit
  attr_accessor :ip, :first_name, :last_name, :phone, :email, :date, :points, :segments, :description

  def order= order
    return unless order
    self.date = order.departure_date
    self.email = order.email
    self.phone = order.phone.try(:gsub, /\D/, '')
    self.description = order.description.presence
  end

  def order_form= order_form
    return unless order_form
    self.flights = order_form.recommendation.variants[0].flights
    self.email = order_form.email
    self.phone = order_form.phone.try(:gsub, /\D/, '')
    self.first_name = order_form.people.first.first_name
    self.last_name = order_form.people.first.last_name
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

end
