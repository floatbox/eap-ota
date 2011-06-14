# encoding: utf-8
class OrderForm < ActiveRecord::BaseWithoutTable
  column :email
  column :phone
  column :payment_type
  column :delivery
  has_many :people
  accepts_nested_attributes_for :people
  attr_writer :card
  attr_accessor :recommendation
  attr_accessor :pnr_number
  attr_accessor :people_count
  attr_accessor :number
  attr_accessor :sirena_lead_pass
  attr_accessor :last_tkt_date
  attr_accessor :order # то, что сохраняется в базу
  attr_accessor :variant_id #нужен при восстановлении формы по урлу

  validates_format_of :email, :with =>
  /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message => "Некорректный email"
  validates_presence_of :email, :phone
  validates_format_of :phone, :with => /^[\d \+\-\(\)]+$/

  def card
    @card || CreditCard.new
  end

  def last_pay_time
    return if recommendation.source == 'sirena'
    return Time.now + 24.hours if Conf.amadeus.env != 'production' # так как тестовый Амадеус в прошлом
    return if recommendation.flights.first.departure_datetime_utc - 72.hours < Time.now
    return unless last_tkt_date
    return if last_tkt_date <= Date.today + 2.days
    #return Time.now + 24.hours - Time.now.min.minutes if last_tkt_date == Date.today + 1.day
    return last_tkt_date.to_time
  end

  def tk_xl
    default_tk_xl = (Time.now.hour < 17 ? Date.today + 1.day : Date.today + 2.days)
    dept_date = recommendation.variants[0].flights[0].dept_date
    last_tkt_date = recommendation.last_tkt_date || default_tk_xl
    if payment_type == 'card'
      [default_tk_xl, dept_date, last_tkt_date + 1.day].min
    else
      last_pay_time.to_date + 1.day
    end
  end


  def adults
    people && (people.sort_by(&:birthday)[0..(people_count[:adults]-1)])
  end

  def children
    s_pos = people_count[:adults]
    e_pos = people_count[:adults] + people_count[:children]-1
    (people && (people_count[:children] > 0) && (people.sort_by(&:birthday)[s_pos..e_pos])) || []
  end

  def infants
    s_pos = people_count[:adults] + people_count[:children]
    (people && (people_count[:infants] > 0) && (people.sort_by(&:birthday)[s_pos..-1])) || []
  end

  def errors_hash
    res = {}
    res['order[email]'] = errors[:email] if errors[:email].present?
    res['order[phone]'] = errors[:phone] if errors[:phone].present?
    res[''] = errors[:recommendation] if errors[:recommendation].present?
    last_flight_word = if recommendation.rt
      "на момент обратного вылета"
    elsif recommendation.segments.length > 1
      "на момент вылета #{recommendation.segments.last.departure.city.case_from} #{recommendation.segments.last.arrival.city.case_to}"
    else
      nil
    end
    people.each_with_index{|p, i|
      unless p.valid?
        p.errors.each do |e,v|
          if last_flight_word && e == :birthday
            res["person[#{i}][#{e}]"] = v.sub('на момент вылета', last_flight_word)
          else
            res["person[#{i}][#{e}]"] = v
          end
        end
      end
    }
    unless card.valid?
      card.errors.each{|e,v|
        res["card[#{e}]"] = v
      }
    end
    res
  end


  def hash
    [recommendation, people_count, people, card].hash
  end

  def save_to_cache
    self.number ||= ShortUrl.random_hash
    Cache.write("order_form", number, self)
  end

  class << self
    def load_from_cache(cache_number)
      require 'segment'
      require 'variant'
      require 'flight'
      require 'recommendation'
      require 'person'
      # FIXME попытаться избавиться от этой загрузки
      Cache.read("order_form", cache_number)
    end
    alias :[] load_from_cache
  end

  def save_to_order
    self.order = Order.create(:order_form => self)
  end

  def variant
    recommendation && recommendation.variants.first
  end

  def init_people
    self.people = (1..(people_count[:adults].to_i + people_count[:children].to_i + people_count[:infants].to_i)).map {|n|
        Person.new
    }
  end

  def seat_total
    people_count[:adults] + people_count[:children]
  end

  validate :validate_card, :validate_dept_date

  def validate_dept_date
    errors.add :recommendation, 'Первый вылет слишком рано' unless TimeChecker.ok_to_sell(recommendation.variants[0].segments[0].dept_date, recommendation.last_tkt_date)
  end

  def validate_card
    if payment_type == 'card'
      errors.add :card, 'Отсутствуют данные карты' unless card
      errors.add :card, 'Некорректные данные карты' if card && !card.valid?
    end
  end

  def set_flight_date_for_childen_and_infants
    last_date = recommendation.flights.last.dept_date
    children.each{|c|
      c.flight_date = last_date
      c.infant_or_child = 'c'
    }
    infants.each{|i|
      i.flight_date = last_date
      i.infant_or_child = 'i'
    }
  end

  def block_money
    response = order.block_money(card)

    if response.error?
      card.errors.add :number, "не удалось провести платеж"
      errors.add :card, 'Платеж не прошел'
    end

    response
  end

  def commission
    recommendation.commission
  end

  def validating_carrier
    recommendation.validating_carrier.iata
  end


  def full_info
    res = ''
    people.every.coded.join("\n")
  end

  def self.create_sample_booking(cache_key)
    order = OrderForm.load_from_cache(cache_key)
    order.email = 'email@example.com'
    order.phone = '12345678'
    order.people_count = {:infants => 1, :children => 1, :adults => 2}
    order.people = [Person.new(
      :first_name => 'Anna',
      :last_name => 'Adult',
      :birthday => Date.today - 19.years,
      :document_expiration_date => Date.today + 1.year,
      :passport => '999999343',
      :nationality_id => 1,
      :sex => 'f',
      :bonus_present => false
    ),
      Person.new(
      :first_name => 'Ivan',
      :last_name => 'Adult',
      :birthday => Date.today - 20.years,
      :document_expiration_date => Date.today + 1.year,
      :passport => '999999999',
      :nationality_id => 1,
      :sex => 'm',
      :bonus_present => true,
      :bonuscard_type => 'SU',
      :bonuscard_number => '345643'
    ),
    Person.new(
      :first_name => 'Masha',
      :last_name => 'Infant',
      :birthday => Date.today - 1.years,
      :document_expiration_date => Date.today + 1.year,
      :passport => '88888888',
      :nationality_id => 1,
      :sex => 'f'
    ),
    Person.new(
      :first_name => 'Masha',
      :last_name => 'Child',
      :birthday => Date.today - 10.years,
      :document_expiration_date => Date.today + 1.year,
      :passport => '77777777',
      :nationality_id => 1,
      :sex => 'f'
    )]
    order.card = Payture.test_card
    order.set_flight_date_for_childen_and_infants
    order.create_booking
  end
end
