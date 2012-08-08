# encoding: utf-8
module InsuranceHelper

  def smart_insurance_uri order_form
    @order_form = order_form
    uri = "http://www.smart-ins.ru/vzr_iframe/light?#{params.to_query}" if params
  end

  private

  def params
    journey = @order_form.recommendation.journey
    { :start_date => convert_date(journey.flights.first.departure_date),
      :end_date => convert_date(journey.flights.last.arrival_date),
      :country => journey.flights.first.arrival.country.alpha2,
      :email => @order_form.email,
      :phone => @order_form.phone,
      :city => journey.flights.first.departure.city.name_ru,
      :buyers => buyers
    }
  rescue
    nil
  end

  def buyers
    buyers = {}
    @order_form.people.each_with_index do |person, index|
      buyers[index.to_s] = {
        'surname' => person.first_name,
        'name' => person.last_name,
        'dob' => person.birthday.strftime('%d.%m.%Y'),
        'sex' => (person.sex == 'f' ? 1 : 0),
        'passport1' => person.passport[0..2],
        'passport2' => person.passport[3..-1] }
    end
    buyers
  end

  def convert_date str
    Date.parse(str.gsub(/^(\d\d)(\d\d?)(\d\d?)$/){"%02d.%02d.%02d" % [$3, $2, $1].map(&:to_i)}).strftime('%d.%m.%Y')
  end
end
