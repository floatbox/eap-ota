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
  attr_writer :price_with_payment_commission
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
    dept_datetime_mow = Location.default.tz.utc_to_local(recommendation.journey.departure_datetime_utc) - 1.hour
    last_ticket_date = self.last_tkt_date || (Date.today + 2.days)
    #эта херня нужна, просто .min не подходит тк dept_datetime_mow
    if dept_datetime_mow.to_date <= last_ticket_date
      dept_datetime_mow
    else
      last_pay_time || (last_ticket_date.to_time + 1.day)
    end
  end

  # пассажиры, летящие по взрослому тарифу
  def adults
    people.find_all{|p| p.adult?(last_flight_date)}
  end

  # пассажиры (в том числе младенцы), летящие по детскому тарифу с выделенным местом
  # работает после assosiate_infants
  def children
    people - adults - infants
  end

  # дети до двух лет, которым не предоставляется места
  # работает только после associate_infants
  def infants
    associated_infants
  end

  #дети до 2-х лет, без явно указанного места
  def  potential_infants
    people.find_all{|p| p.potential_infant?(last_flight_date) }
  end

  # взрослые без детей на коленях
  def childfree_adults
    adults.reject(&:associated_infant)
  end

  # младенцы, которых уже распределили по коленям взрослых пассажиров
  def associated_infants
    adults.map(&:associated_infant).compact
  end

  # младенцы, которых еще не распределили по коленям взрослых пассажиров
  # на текущий момент младенцы с местом должны попадать в категорию children
  # FIXME - проверять ли в valid orphans.empty?
  def orphans
    potential_infants - associated_infants
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

  def price_with_payment_commission
    @price_with_payment_commission ||= recommendation.price_with_payment_commission
  end

  def save_to_cache
    cache = OrderFormCache.new
    copy_attrs self, cache, :recommendation, :people_count, :variant_id, :query_key, :partner, :marker, :price_with_payment_commission
    cache.save
    self.number = cache.id.to_s
  end

  def update_in_cache
    cache = OrderFormCache.find(number) or raise(NotFound, "#{number} not found")
    copy_attrs self, cache, :recommendation, :people_count, :variant_id, :query_key, :partner, :marker, :price_with_payment_commission
    cache.save
  end

  class NotFound < StandardError; end
  class << self
    def load_from_cache(cache_number)
      cache = OrderFormCache.find(cache_number) or raise(NotFound, "#{cache_number} not found")
      order = new
      copy_attrs cache, order, :recommendation, :people_count, :variant_id, :query_key, :partner, :marker, :price_with_payment_commission
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
    recommendation.try(:journey)
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
      errors.add :recommendation, 'Первый вылет слишком рано' unless TimeChecker.ok_to_sell(recommendation.journey.departure_datetime_utc, recommendation.last_tkt_date)
    elsif recommendation.source == 'sirena'
      errors.add :recommendation, 'Первый вылет слишком рано' unless TimeChecker.ok_to_sell_sirena(recommendation.journey.departure_datetime_utc)
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
    associate_infants
    set_childen_and_infants
    unless people.all?(&:valid?)
      errors.add :people, 'Проверьте данные пассажиров'
    end
  end

  def update_price_and_counts
    search = PricerForm.load_from_cache(query_key)
    search.people_count = calculated_people_count
    strategy = Strategy.select( :rec => recommendation, :search => search )
    if strategy.check_price_and_availability
      self.people_count = search.people_count
      self.price_with_payment_commission = recommendation.price_with_payment_commission
      update_in_cache
      return true
    end
  end

  def counts_contradiction
    valid?
    people_count != calculated_people_count
  end

  def last_flight_date
    recommendation.segments.last.dept_date
  end

  def calculated_people_count
    {:adults => adults.count, :children => children.count, :infants => infants.count}
  end

  def set_childen_and_infants
    children.each{|c|
      c.child = true
    }
    infants.each{|i|
      i.infant = true
    }
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

  def associate_infants
    # идем по порядку, привязываем каждого младенца к предшествующему по порядку взрослому
    people.each_cons(2) do |person, next_person|
      next if person.associated_infant
      if person.adult?(last_flight_date) && next_person.potential_infant?(last_flight_date)
        person.associated_infant = next_person
      end
    end

    # пытаемся идентифицировать схожесть фамилий
    orphans.each do |infant|
      if adult = childfree_adults.find { |adult| similar_last_names? infant.last_name, adult.last_name }
        adult.associated_infant = infant
      end
    end

    # распихиваем оставшихся
    orphans.zip( childfree_adults ).each do |orphan, adult|
      adult.associated_infant = orphan if adult
    end
  end

  private

  LONGEST_ENDING = 3
  SHORTEST_STEM = 3
  # похожесть фамилий без учета мужских и женских окончаний
  def similar_last_names? first_name, second_name
    max_length = [first_name.length, second_name.length].max
    stem_length = [max_length - LONGEST_ENDING, SHORTEST_STEM].max
    first_name[0, stem_length] == second_name[0, stem_length]
  end
end

