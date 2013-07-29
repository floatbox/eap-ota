# encoding: utf-8
module InsuranceHelper

  def sravnikupi_insurance_uri order_form
    return unless uri_params = sravnikupi_uri_params(order_form)
    # пока не показываем страховку для России
    return if uri_params['country_code'] == 'RU'
    "http://www.sravnikupi.ru/?pid=251_291_219_42369&travel=1&calculate=1&#{uri_params.to_query}"
  end

  def smart_insurance_uri order_form
    return unless uri_params = smart_insurance_uri_params(order_form)
    # пока не показываем страховку для России
    return if uri_params['country'] == 'RU'
    "https://www.smart-ins.ru/vzr_iframe/light?#{uri_params.to_query}"
  end

  def cherehapa_insurance_uri order_form
    return unless uri_params = sravnikupi_uri_params(order_form)
    # пока не показываем страховку для России
    return if uri_params['country_code'] == 'RU'
    "https://partners.cherehapa.ru/widget/jsbanner/eviterra.html?#{uri_params.to_query}"
  end

  def sravnikupi_uri_params order_form
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
    { 'date_range' => smart_insurance_date(insurance_start_date) + '-' + smart_insurance_date(insurance_end_date),
      'country_code' => journey.segments.first.arrival.country.alpha2,
      'email' => order_form.email,
      'phone' => order_form.phone,
      'insurants' => order_form.people.count,
      'passengers' => sravnikupi_insurance_buyers(order_form.people.sort_by(&:birthday)),
    }
  end

  def smart_insurance_uri_params order_form
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
      'buyers' => smart_insurance_buyers(order_form.people.sort_by(&:birthday)),
      'partner' => 'eviterra'
    }
  end

  def sravnikupi_insurance_buyers people
    buyers = {}
    people.each_with_index do |person, index|
      buyers[index.to_s] = {
        'name_last' => person.last_name,
        'name_first' => person.first_name,
        'birth_date' => smart_insurance_date(person.birthday),
        'gender' => (person.sex == 'f' ? '2' : '1'),
        'nationality' => (person.nationality.iata == 'RU' ? '1' : '0'),
        'doc_series' => person.cleared_passport[0..1],
        'doc_num' => person.cleared_passport[2..-1] }
    end
    buyers
  end

  def smart_insurance_buyers people
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
