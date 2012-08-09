# encoding: utf-8
module InsuranceHelper

  def smart_insurance_uri order_form
    @order_form = order_form
    uri = "https://www.smart-ins.ru/vzr_iframe/light?#{uri_params.to_query}" if uri_params
  end

  private

  def uri_params
    journey = @order_form.recommendation.journey
    route = @order_form.recommendation.variants.first.segments.inject([]){|route,s|route+=[s.flights.first.departure]+[s.flights.last.arrival]}
    start_date = convert_date(journey.flights.first.departure_date)
    { :start_date => start_date,
      :end_date => (@order_form.recommendation.rt ? convert_date(journey.flights.last.arrival_date) : (Date.parse(start_date) + 30.days).strftime('%d.%m.%Y')),
      :country => route.second.country.alpha2,
      :email => @order_form.email,
      :phone => @order_form.phone,
      :city => journey.flights.first.departure.city.name_ru,
      :buyers => buyers,
      :partner => 'eviterra'
    }
  end

  def buyers
    buyers = {}
    @order_form.people_by_age.each_with_index do |person, index|
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

  def convert_date str
    Date.parse(str.gsub(/^(\d\d)(\d\d?)(\d\d?)$/){"%02d.%02d.%02d" % [$3, $2, $1].map(&:to_i)}).strftime('%d.%m.%Y')
  end
end
