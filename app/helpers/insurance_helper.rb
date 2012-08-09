# encoding: utf-8
module InsuranceHelper

  def smart_insurance_uri order_form
    uri_params = insurance_uri_params(order_form)
    uri = "https://www.smart-ins.ru/vzr_iframe/light?#{uri_params.to_query}" if uri_params
  end

  def insurance_uri_params order_form
    journey = order_form.recommendation.journey
    start_date = smart_insurance_date(journey.flights.first.departure_date)
    insurance_end_date = if journey.segments.count > 1
      smart_insurance_date(journey.flights.last.arrival_date)
    else
      (Date.parse(start_date) + 30.days).strftime('%d.%m.%Y')
    end
    { :start_date => start_date,
      :end_date => insurance_end_date,
      :country => journey.segments.first.flights.last.arrival.country.alpha2,
      :email => order_form.email,
      :phone => order_form.phone,
      :city => journey.flights.first.departure.city.name_ru,
      :buyers => insurance_buyers(order_form.people_by_age),
      :partner => 'eviterra'
    }
  end

  def insurance_buyers people
    buyers = {}
    people.each_with_index do |person, index|
      buyers[index.to_s] = {
        'surname' => person.first_name,
        'name' => person.last_name,
        'dob' => person.birthday.strftime('%d.%m.%Y'),
        'sex' => (person.sex == 'f' ? 1 : 0),
        'passport1' => person.cleared_passport[0..1],
        'passport2' => person.cleared_passport[2..-1] }
    end
    buyers
  end

  def smart_insurance_date str
    Date.parse(str.gsub(/^(\d\d)(\d\d?)(\d\d?)$/){"%02d.%02d.%02d" % [$3, $2, $1].map(&:to_i)}).strftime('%d.%m.%Y')
  end
end
