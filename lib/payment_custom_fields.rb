class PaymentCustomFields
  include KeyValueInit
  attr_accessor :ip, :first_name, :last_name, :phone, :email, :date, :points, :segments, :description

  def order= order
    self.date = order.departure_date
    self.email = order.email
    self.phone = order.phone.gsub(/\D/, '') if order.phone
    self.description = order.description if order.description.present?
  end

  def order_form= order_form
    if order_form
      self.date = order_form.recommendation.variants[0].flights[0].dept_date
      self.email = order_form.email
      self.phone = order_form.phone.gsub(/\D/, '')
      self.first_name = order_form.people.first.first_name
      self.last_name = order_form.people.first.last_name
      self.points = []
      order_form.recommendation.variants[0].flights.every.departure_iata.zip(
        order_form.recommendation.variants[0].flights.every.arrival_iata).flatten.each_cons(2) do |f, s|
          self.points << f if f != s
        end
      self.segments = points.length - 1
    end
  end

end
