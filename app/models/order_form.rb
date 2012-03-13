# encoding: utf-8
class OrderForm
  include ActiveModel::Validations
  extend ActiveModel::Callbacks
  define_model_callbacks :validation
  include KeyValueInit
  include CopyAttrs
  extend CopyAttrs

  attr_accessor :email
  attr_accessor :phone
  attr_accessor :payment_type
  attr_accessor :delivery
  attr_accessor :people
  #accepts_nested_attributes_for :people

  attr_writer :card
  attr_accessor :recommendation
  attr_accessor :pnr_number
  attr_accessor :people_count
  attr_accessor :query_key
  attr_accessor :partner
  attr_accessor :marker
  attr_accessor :number
  attr_accessor :sirena_lead_pass
  attr_accessor :order # то, что сохраняется в базу
  attr_accessor :variant_id #нужен при восстановлении формы по урлу
  attr_reader :show_vat, :vat_included

  delegate :last_tkt_date, :to => :recommendation
  validates_format_of :email, :with =>
  /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message => "Некорректный email"
  validates_presence_of :email, :phone
  validates_format_of :phone, :with => /^[\d \+\-\(\)]+$/

  def card
    @card || CreditCard.new
  end

  def last_pay_time
    return if Conf.site.forbidden_cash
    return if recommendation.source == 'sirena'
    return Time.now + 24.hours if Conf.amadeus.env != 'production' && !Rails.env.test? # так как тестовый Амадеус в прошлом
    return if recommendation.flights.first.departure_datetime_utc - 72.hours < Time.now
    return unless last_tkt_date
    return if last_tkt_date <= Date.new(2012, 1, 11)
    return if last_tkt_date <= Date.today
    return Time.now + 24.hours - Time.now.min.minutes if last_tkt_date == Date.today + 1.day
    return last_tkt_date.to_time
  end

  def tk_xl
    dept_datetime_mow = Location.default.tz.utc_to_local(recommendation.variants[0].departure_datetime_utc) - 1.hour
    last_ticket_date = self.last_tkt_date || (Date.today + 2.days)
    #эта херня нужна, просто .min не подходит тк dept_datetime_mow
    if dept_datetime_mow.to_date <= last_ticket_date
      dept_datetime_mow
    else
      last_pay_time || (last_ticket_date.to_time + 1.day)
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

  def people_attributes= attrs
    @people ||= []
    attrs.each do |k, person_attrs|
      @people[k.to_i] = Person.new(person_attrs)
    end
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
    cache = OrderFormCache.new
    copy_attrs self, cache, :recommendation, :people_count, :variant_id, :query_key, :partner, :marker
    cache.save
    self.number = cache.id.to_s
  end

  class NotFound < StandardError; end
  class << self
    def load_from_cache(cache_number)
      cache = OrderFormCache.find(cache_number) or raise(NotFound, "#{cache_number} not found")
      order = new
      copy_attrs cache, order, :recommendation, :people_count, :variant_id, :query_key, :partner, :marker
      order.number = cache.id.to_s
      order
    end

    alias :[] load_from_cache
  end

  def save_to_order
    self.order ||= Order.create(:order_form => self)
    order.save
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

  validate :validate_card, :validate_dept_date, :validate_people

  def validate_dept_date
    if recommendation.source == 'amadeus'
      errors.add :recommendation, 'Первый вылет слишком рано' unless TimeChecker.ok_to_sell(recommendation.variants[0].departure_datetime_utc, recommendation.last_tkt_date)
    elsif recommendation.source == 'sirena'
      errors.add :recommendation, 'Первый вылет слишком рано' unless TimeChecker.ok_to_sell_sirena(recommendation.variants[0].departure_datetime_utc)
    end
  end

  def validate_card
    if payment_type == 'card'
      errors.add :card, 'Отсутствуют данные карты' unless card
      errors.add :card, 'Некорректные данные карты' if card && !card.valid?
    end
  end

  # FIXME убрать внутрь Person
  def validate_people
    people.each(&:set_birthday)
    people.each(&:set_document_expiration_date)
    set_flight_date_for_childen_and_infants
    unless people.all?(&:valid?)
      errors.add :people, 'Проверьте данные пассажиров'
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

  def block_money(ip = nil)
    response = order.block_money(card, self, ip)

    if response.error?
      card.errors.add :number, "не удалось провести платеж"
      errors.add :card, 'Платеж не прошел'
    end

    response
  end

  def agent_commission
    recommendation.commission_agent
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
    order.valid?
    order.create_booking
  end
end

