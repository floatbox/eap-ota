# encoding: utf-8
module InsuranceHelper

  def smart_insurance_uri order_form
    return unless uri_params = insurance_uri_params(order_form)
    # пока не показываем страховку для России
    return if uri_params['country'] == 'RU'
    "https://www.smart-ins.ru/vzr_iframe/light?#{uri_params.to_query}"
  end

  def insurance_uri_params order_form
    return unless order_form
    return unless order_form.recommendation
    journey = order_form.recommendation.journey
    insurance_start_date = journey.segments.first.dept_date
    insurance_end_date =
      if journey.segments.count > 1
        journey.segments.last.arrv_date
      else
        insurance_start_date + 30.days
      end
    { 'start_date' => smart_insurance_date(insurance_start_date),
      'end_date' => smart_insurance_date(insurance_end_date),
      'country' => journey.segments.first.arrival.country.alpha2,
      'email' => order_form.email,
      'phone' => order_form.phone,
      'city' => journey.flights.first.departure.city.name_en,
      'buyers' => insurance_buyers(order_form.people_by_age_and_seat),
      'partner' => 'eviterra'
    }
  end

  def insurance_buyers people
    buyers = {}
    people.each_with_index do |person, index|
      buyers[index.to_s] = {
        'surname' => person.last_name,
        'name' => person.first_name,
        'dob' => smart_insurance_date(person.birthday),
        'sex' => (person.sex == 'f' ? '1' : '0'),
        'passport1' => person.cleared_passport[0..1],
        'passport2' => person.cleared_passport[2..-1] }
    end
    buyers
  end

  def smart_insurance_date date
    date.strftime('%d.%m.%Y')
  end
end
