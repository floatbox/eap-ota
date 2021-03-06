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
  attr_accessor :delivery
  attr_accessor :people
  #accepts_nested_attributes_for :people

  attr_accessor :recommendation
  attr_writer :price_with_payment_commission
  attr_accessor :pnr_number
  attr_accessor :people_count
  attr_accessor :query_key
  attr_accessor :partner
  # FIXME убрать через пару дней 2013-12-05, избавляемся от косяков в order_form_caches
  def partner=(partner)
    @partner = partner if partner.present? && !partner['Partner']
  end
  attr_accessor :marker
  attr_accessor :number
  attr_accessor :order # то, что сохраняется в базу
  # Снимает ограничения на бронирование. Параметр не сохраняется в кэш.
  attr_accessor :context
  attr_reader :show_vat, :vat_included

  # на переходный период
  def payment_type=(value)
    payment.type = value
  end

  def payment_type
    payment.type
  end

  delegate :last_tkt_date, :to => :recommendation
  validates :email,
    presence: true,
    mx_record: true,
    format:
      { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, message: "Некорректный email" }
  validates :phone,
    presence: true,
    format:
      { with: /\A[\d \+\-\(\)]+\z/, message: 'Некорректный номер телефона' }

  def last_pay_time
    return Time.now + 24.hours if Conf.amadeus.env != 'production' && !Rails.env.test? # так как тестовый Амадеус в прошлом
    return if recommendation.flights.first.departure_datetime_utc - 72.hours < Time.now
    return unless last_tkt_date
    return if last_tkt_date <= Date.new(2012, 1, 11)
    return if last_tkt_date <= Date.today
    return Time.now + 24.hours - Time.now.min.minutes if last_tkt_date == Date.today + 1.day
    return last_tkt_date.to_time
  end

  # разрешает сделать бронирование с оплатой потом.
  def allowed_delayed_payment?
    return false unless context.enabled_delayed_payment?
    context.lax? || !!last_pay_time
  end
  delegate :enabled_delivery?, :enabled_cash?, to: :context

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
  def potential_infants
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

  def persons= attrs
    attrs = url_encoded_array_to_proper attrs
    @people = attrs.map {|person| Person.new person}
  end

  def payment= attrs
    @payment = PaymentForm.new attrs
  end

  def payment
    @payment ||= PaymentForm.new
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
    unless payment.card.valid?
      payment.card.errors.each{|e,v|
        res["card[#{e}]"] = v
      }
    end
    res
  end


  def hash
    [recommendation, people_count, people, payment.card].hash
  end

  def info_hash
    {:prices => {
        :fare => recommendation.price_fare.round(2),
        :tax_and_markup => (recommendation.price_with_payment_commission - recommendation.price_fare).round(2),
        :total => recommendation.price_with_payment_commission.round(2),
        :discount => recommendation.price_discount.round(2),
        :fee => recommendation.fee.round(2)
      },
      :rules => recommendation.rules
    }
  end

  def price_with_payment_commission
    @price_with_payment_commission ||= recommendation.price_with_payment_commission
  end

  def save_to_cache
    cache = OrderFormCache.new
    copy_attrs self, cache, :recommendation, :people_count, :query_key, :partner, :marker, :price_with_payment_commission
    cache.with(safe: true).save
    self.number = cache.id.to_s
    Rails.logger.info "OrderForm: creating id #{number}"
  end

  def update_in_cache
    cache = OrderFormCache.find(number) or raise(NotFound, "#{number} not found")
    copy_attrs self, cache, :recommendation, :people_count, :query_key, :partner, :marker, :price_with_payment_commission
    cache.with(safe: true).save
  end

  class NotFound < StandardError; end
  class << self
    def load_from_cache(cache_number)
      cache = OrderFormCache.find(cache_number) or raise(NotFound, "#{cache_number} not found")
      order = new
      copy_attrs cache, order, :recommendation, :people_count, :query_key, :partner, :marker, :price_with_payment_commission
      order.number = cache.id.to_s
      order
    end

    alias :[] load_from_cache
  end

  def save_to_order
    self.order ||= Order.create(:order_form => self)
    order.save
  end

  def needs_visa_notification
    recommendation.flights.any?{|f| f.arrival.country.alpha2 == 'US' &&
                                    f.departure.country.alpha2 != 'US'} &&
      people.any?{|p| ['RU', 'BY', 'UA', 'KZ'].include?(p.nationality.alpha2)}
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

  validate :validate_card, if: ->{payment.type == 'card'}
  validate :validate_dept_date, if: ->{!context.lax? && recommendation.source == 'amadeus'}
  validate :validate_people

  def validate_dept_date
    if !TimeChecker.ok_to_sell(recommendation.journey.departure_datetime_utc, recommendation.last_tkt_date)
      errors.add :recommendation, 'Первый вылет слишком рано'
    end
  end

  def validate_card
    if payment.card
      errors.add :card, 'Некорректные данные карты' unless payment.card.valid?
    else
      errors.add :card, 'Отсутствуют данные карты'
    end
  end

  # FIXME убрать внутрь Person
  def validate_people
    associate_infants
    set_childen_and_infants
    unless people.all?(&:valid?)
      errors.add :people, 'Проверьте данные пассажиров'
    end
  end

  def update_price_and_counts
    search = AviaSearch.from_code(query_key)
    search.people_count = calculated_people_count
    strategy = Strategy.select( :rec => recommendation, :search => search, :context => context )
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

  def price_contradiction
    valid?
    difference = payment.amount - recommendation.price_with_payment_commission
    result = difference.abs > 1
    Rails.logger.info "Price contradiction: #{payment.amount} - #{recommendation.price_with_payment_commission} = #{difference} : #{result}"
    result
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

  def url_encoded_array_to_proper struct
    return struct if struct.is_a?(Array)
    raise ArgumentError unless url_encoded_array?(struct)
    struct.sort_by {|k, v| k}.map(&:last)
  end

  def url_encoded_array? struct
    return false unless struct.is_a?(Hash)
    return false unless struct.keys.map(&:to_i).sort.first == 0
    true
  end

end

