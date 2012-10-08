# encoding: utf-8
class Ticket < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  include CopyAttrs
  has_paper_trail

  # FIXME вынести в ActiveRecord::Base
  def in_identity_map?
    id && self.equal?( ActiveRecord::IdentityMap.get(self.class, id) )
  end

  # FIXME сделать модуль или фикс для typus, этим оверрайдам место в typus/application.yml
  def self.model_fields
    super.merge(
      :price_payment_commission => :decimal,
      :price_with_payment_commission => :decimal,
      :income => :decimal,
      :income_suppliers => :decimal,
      :income_payment_gateways => :decimal
    )
  end

  belongs_to :order
  belongs_to :parent, :class_name => 'Ticket'
  has_many :refunds, :class_name => 'Ticket', :foreign_key => 'parent_id', :conditions => 'kind = "refund"'
  has_one :replacement, :class_name => 'Ticket', :foreign_key => 'parent_id', :conditions => 'kind ="ticket"'
  has_many :children, :class_name => 'Ticket', :foreign_key => 'parent_id'

  has_and_belongs_to_many :stored_flights
  serialize :baggage_info, JoinedArray.new

  # для отображения в админке билетов. Не очень понятно,
  # как запретить добавление новых, впрочем.
  has_many :other_tickets, :readonly => true,
    :through => :order, :source => :tickets, :order => 'tickets.number asc',
    :conditions => lambda {|_| ["tickets.id <> ?", id] }

  delegate :need_attention, :paid_by, :to => :order

  delegate :commission_carrier, :to => :order, :allow_nil => true

  delegate :old_booking, :to => :order, :allow_nil => true

  # FIXME - временно, эквайринг должен браться из суммы пейментов
  delegate :acquiring_percentage, :to => :order

  extend Commission::Columns
  has_commission_columns :commission_agent, :commission_subagent, :commission_consolidator, :commission_blanks, :commission_discount, :commission_our_markup
  include Pricing::Ticket
# set_refund_data нужно запускать до check_currency
  before_validation :set_refund_data, :if => lambda {kind == "refund"}
  before_validation :update_prices_and_add_parent, :if => :original_price_total
  before_validation :check_currency, :if => :ticketed_date
  before_save :recalculate_commissions, :set_validating_carrier

  scope :uncomplete, where(:ticketed_date => nil)
  scope :sold, where(:status => ['ticketed', 'exchanged', 'returned', 'processed'])

  validates_presence_of :price_fare, :price_tax, :price_our_markup, :price_penalty, :price_discount, :price_consolidator, :if => lambda {kind = 'refund'}
  after_save :update_parent_status, :if => :parent
  after_destroy :update_parent_status, :if => :parent
  validates_presence_of :comment, :if => lambda {kind == "refund"}
  after_save :update_prices_in_order
  attr_accessor :parent_number, :parent_code, :original_price_total
  attr_writer :price_fare_base, :flights
  before_validation :set_info_from_flights

  def show_vat
    vat_status != 'unknown'
  end

  def set_info_from_flights
    if @flights
      if [nil, '', 'unknown'].include? vat_status
        if @flights[0].departure.country.iata != 'RU' ||
            @flights.last.arrival.country.iata != 'RU' ||
            @flights.map{|f| [f.departure, f.arrival]}.flatten.uniq.map{|ap| ap.country.iata}.count('RU') < 2
          self.vat_status = '0'
        elsif @flights.map{|f| [f.departure.country.iata, f.arrival.country.iata]}.flatten.uniq == ['RU']
          self.vat_status = '18%'
        else
          self.vat_status = 'unknown'
        end
      end
      self.route = @flights.map{|fl| "#{fl.departure_iata} \- #{fl.arrival_iata} (#{fl.marketing_carrier_iata})"}.uniq.join('; ')
      self.cabins = @flights.every.cabin.compact.join(' + ')
      self.dept_date = @flights.first.dept_date

      # и закидываем в базу
      self.stored_flights = @flights.map {|fl| StoredFlight.from_flight(fl) } if Conf.site.store_flights
    end
  end

  def flights
    stored_flights.map(&:to_flight).sort_by(&:departure_datetime_utc)
  end

  def booking_classes
    cabins.split(' + ')
  end

  def price_fare_base 
    @price_fare_base ||= if parent
      original_price_fare + parent.price_fare_base
    else
      original_price_fare
    end
  rescue TypeError
  #  TODO: придумать, что делать в случае несовпадения типов
  end

   # whitelist офис-айди, имеющих к нам отношение. В брони иногда попадают "не наши" билеты
   # для всех айди в базе можно использовать: Ticket.uniq.pluck(:office_id).compact.sort
   def self.office_ids
     ['MOWR2233B', 'MOWR228FA', 'MOWR2219U', 'NYC1S21HX', 'FLL1S212V']
   end

  def self.validating_carriers
    Carrier.uniq.pluck(:iata).sort
  end

  def baggage_array
    baggage_info.map{|code| [BaggageLimit.deserialize(code)]}
  end

  def update_prices_and_add_parent
    if parent_number
      if exchanged_ticket = order.tickets.select{|t| t.code.to_s == parent_code.to_s && t.number.to_s[0..9] == parent_number.to_s}.first
        self.parent = exchanged_ticket
        if price_fare_base && price_fare_base > 0
          self.original_price_tax = original_price_total - price_fare_base + parent.price_fare_base #в противном случае tax может получиться отрицательным
          self.original_price_fare = price_fare_base - parent.price_fare_base
        end
      end
    else
      self.original_price_tax = original_price_total - original_price_fare
    end
  rescue TypeError
  #  TODO: придумать, что делать в случае несовпадения типов
  end

  def update_parent_status
    parent.update_status
  end

  def update_status
    if kind == 'ticket'
      if order.tickets.where(:kind => 'ticket', :parent_id => id).present? #select{|t| t.parent_id == id && t.kind == 'ticket'}.present?
        update_attribute(:status, 'exchanged')
      elsif order.tickets.where(:parent_id => id, :kind => 'refund', :status => 'processed').present? #.select{|t| t.parent_id == id && t.kind == 'refund' && t.status == 'processed'}.present?
        update_attribute(:status, 'returned')
      else
        update_attribute(:status, 'ticketed')
      end
    end
  end

  def set_validating_carrier
    self.validating_carrier = Carrier.where(:code => code).first.try(:iata) if validating_carrier.blank?
  end

  def replacement_number_with_code
    replacement.number_with_code if replacement
  end

  def parent_number_with_code
    parent.number_with_code if parent
  end

  def refund
    refunds.last
  end

  def recalculated_price_with_payment_commission
    price_with_payment_commission
  end

  def commission_ticketing_method
    case office_id
    when 'MOWR228FA'
      'direct'
    when 'FLL1S212V'
      'downtown'
    else
      'aviacenter'
    end
  end

  def self.validators
    uniq.pluck(:validator).compact.sort
  end

  def self.sources
    ['amadeus', 'sirena']
  end

  def self.statuses
    ['ticketed', 'voided', 'pending', 'exchanged', 'returned', 'processed']
  end

  def processed
    (kind == 'ticket') || (status == 'processed')
  end

  def self.kinds
    ['ticket', 'refund']
  end

  def self.ensure_exists number
    raise ArgumentError, 'ticket number is blank' if number.blank?
    find_or_initialize_by_number number
  end

  def update_prices_in_order
    # FIXME убить или оставить только ради тестов?
    order.update_prices_from_tickets if order
  end

  def set_refund_data
    if new_record?
      copy_attrs parent, self,
        :validator,
        :office_id,
        :first_name,
        :last_name,
        :passport,
        :commission_subagent,
        :commission_agent,
        :pnr_number,
        :order,
        :code,
        :number,
        :source,
        :validating_carrier
      self.status = 'pending' if status.blank?
    end
    self.price_penalty *= -1 if price_penalty < 0
    self.price_discount *= -1 if price_discount > 0
    self.price_our_markup *= -1 if price_our_markup > 0
    self.original_price_tax *= -1 if original_price_tax.cents > 0
    self.original_price_fare *= -1 if original_price_fare.cents > 0
    self.price_consolidator *= -1 if price_consolidator > 0
    self.commission_subagent = 0 if original_price_fare != -parent.original_price_fare && !parent.commission_subagent.percentage?
    self.commission_agent = 0 if original_price_fare != -parent.original_price_fare && !parent.commission_agent.percentage?
  end

  def copy_commissions_from_order
    return unless order
    # FIXME почему не copy_attrs?
    for attr in [ :commission_agent, :commission_subagent, :commission_consolidator, :commission_blanks, :commission_discount, :commission_our_markup ]
      #if send(attr).nil?
        send("#{attr}=", order.send(attr))
      #end
    end
  end

  def number_with_code
    "#{code}-#{number}" if number.present?
  end

  def self.find_by_number_with_code(number_with_code)
    code, number = number_with_code.split('-',2)
    find_by_code_and_number(code, number)
  end
  class << self
    alias_method :[], :find_by_number_with_code
  end

  # номер первого билета для conjunction
  def first_number
    number.sub /-.*/, '' if number.present?
  end

  def vat_selector
    ['0', '18%', 'unknown'].map do |vat_st|
      if vat_status == vat_st
        "<span class='selected_vat'> #{vat_status} </span>"
      else
        "<a href='/admin/tickets/change_vat/#{id}?vat_status=#{CGI::escape(vat_st)}' class='unselected_vat'><span class='unselected_vat'> #{vat_st} </span></a>"
      end
    end.join(' <br> ').html_safe
  end

  def refund_url
    if kind == 'ticket'
      "<a href='/admin/tickets/new_refund?_popup=true&&resource[kind]=refund&resource[parent_id]=#{id}' class='iframe_with_page_reload'>Add refund</a>".html_safe
    end
  end

  def confirm_refund_url
    if kind == 'refund'
      CustomTemplate.new.render(:partial => "admin/tickets/refund_actions", :locals => {:ticket => self}).html_safe
    end
  end

  def first_number_with_code
    "#{code}-#{first_number}" if number.present?
  end

  def name
    "#{last_name} #{first_name}"
  end

  def carrier
    validating_carrier.present? ? validating_carrier : commission_carrier
  end

  def check_currency
    if original_fare_currency && original_fare_currency != "RUB"
      self.price_fare = CBR.exchange_on(ticketed_date).exchange_with(original_price_fare,"RUB").to_f
    end
    if original_tax_currency && original_tax_currency != "RUB"
      self.price_tax = CBR.exchange_on(ticketed_date).exchange_with(original_price_tax,"RUB").to_f
    end
    self.price_fare = original_price_fare.to_f if original_fare_currency == "RUB"
    self.price_tax = original_price_tax.to_f if original_tax_currency == "RUB"
  end

  # для тайпуса
  def description
    CustomTemplate.new.render(:partial => "admin/tickets/description", :locals => {:ticket => self}).html_safe
  end

  # для админки
  def to_label
    "#{source} #{number} #{route} #{updated_at}"
  end

  def link_to_show
    url = url_for(:controller => 'admin/tickets', :action => :show, :id => id, :only_path => true)
    "<a href=#{url}>#{number_with_code}</a>".html_safe
  end

  def customized_original_fare
    original_price_fare ? original_price_fare.with_currency : 'Unknown'
  end

  def customized_original_tax
    original_price_tax ? original_price_tax.with_currency : 'Unknown'
  end

  def itinerary_receipt
    if order && !new_record?
      url = show_order_for_ticket_path(order.pnr_number, self)
      "<a href=#{url}>PNR</a><br/><br/><a href=#{url}?lang=EN>PNR EN</a>".html_safe
    end
  end

  def raw
    Strategy.select(:ticket => self).raw_ticket
  rescue => e
    e.message
  end

  composed_of :original_price_fare,
  :class_name => "Money",
  :mapping => [%w(original_fare_cents cents), %w(original_fare_currency currency_as_string)],
  :constructor => Proc.new { |original_fare_cents, original_fare_currency| original_fare_cents ? Money.new(original_fare_cents, original_fare_currency || Money.default_currency) : nil} ,
  :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : raise(ArgumentError, "Can't convert #{value.class} to Money") }

  composed_of :original_price_tax,
  :class_name => "Money",
  :mapping => [%w(original_tax_cents cents), %w(original_tax_currency currency_as_string)],
  :constructor => Proc.new { |original_tax_cents, original_tax_currency| original_tax_cents ? Money.new(original_tax_cents, original_tax_currency || Money.default_currency)  : nil},
  :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : raise(ArgumentError, "Can't convert #{value.class} to Money") }
end
