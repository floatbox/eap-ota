# encoding: utf-8
class Ticket < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  include CopyAttrs
  has_paper_trail

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
  has_commission_columns :commission_agent, :commission_subagent, :commission_consolidator, :commission_blanks, :commission_discount
  include Pricing::Ticket

  before_save :recalculate_commissions

  scope :uncomplete, where(:ticketed_date => nil)

  before_validation :set_refund_data, :if => lambda {kind == "refund"}
  validates_presence_of :comment, :if => lambda {kind == "refund"}
  after_save :update_prices_in_order

  # FIXME сделать перечисление прямо из базы, через uniq
  def self.office_ids
    ['MOWR2233B', 'MOWR228FA', 'MOWR2219U']
  end

  def refund
    refunds.last
  end

  def recalculated_price_with_payment_commission
    price_with_payment_commission
  end

  def commission_ticketing_method
    if source == 'amadeus' && office_id == 'MOWR228FA'
      'direct'
    else
      'aviacenter'
    end
  end

  def self.validators
    ['92223412', '92228065']
  end

  def self.sources
    ['amadeus', 'sirena']
  end

  def self.statuses
    ['ticketed', 'voided', 'pending', 'exchanged']
  end

  def self.ensure_exists number
    raise ArgumentError, 'ticket number is blank' if number.blank?
    find_or_initialize_by_number number
  end

  def update_prices_in_order
    # FIXME убить или оставить только ради тестов?
    return unless order
    order.tickets.reload if order
    order.update_prices_from_tickets if order
  end

  def set_refund_data
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
    self.price_penalty *= -1 if price_penalty < 0
    self.price_discount *= -1 if price_discount > 0
    self.price_tax *= -1 if price_tax > 0
    self.price_fare *= -1 if price_fare > 0
    self.price_consolidator *= -1 if price_consolidator > 0
    self.commission_subagent = 0 if price_fare != -parent.price_fare && !parent.commission_subagent.percentage?
    self.commission_agent = 0 if price_fare != -parent.price_fare && !parent.commission_agent.percentage?
  end

  def copy_commissions_from_order
    return unless order
    for attr in [ :commission_agent, :commission_subagent, :commission_consolidator, :commission_blanks, :commission_discount ]
      #if send(attr).nil?
        send("#{attr}=", order.send(attr))
      #end
    end
  end

  def ticket_date
    created_at.strftime('%d.%m.%Y') if created_at
  end

  def number_with_code
    "#{code}-#{number}" if number.present?
  end

  # номер первого билета для conjunction
  def first_number
    number.sub /-.*/, '' if number.present?
  end

  def refund_url
    if kind == 'ticket'
      "<a href='/admin/tickets/new_refund?_popup=true&&resource[kind]=refund&resource[parent_id]=#{id}' class='iframe_with_page_reload'>Add refund</a>".html_safe
    end
  end

  def confirm_refund_url
    if kind == 'refund'
      "<a href='/admin/tickets/confirm_refund/#{id}?_popup=true' class='iframe_with_page_reload'>#{processed ? 'Отменить подтверждение' : 'Подтвердить'}</a>".html_safe
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

  # для тайпуса
  def description
    if kind == 'ticket'
      (
      "Билет  № #{link_to_show} <br>" +
        if self.refund
          "есть #{!refund.processed ? 'неподтвержденный клиентом' : ''} возврат <br>"
        end.to_s +
        "<a href='/admin/tickets/new_refund?_popup=true&&resource[kind]=refund&resource[parent_id]=#{id}' class='iframe_with_page_reload'>Добавить возврат</a>"

      ).html_safe
    elsif kind == 'refund'
      (
      "Возврат для билета № #{link_to_show} <br>" +
      "Сумма к возварату: #{price_refund} рублей"
      ).html_safe
    end
  end

  # для админки
  def to_label
    "#{source} #{number} #{route} #{updated_at}"
  end

  def link_to_show
    url = url_for(:controller => 'admin/tickets', :action => :show, :id => id, :only_path => true)
    "<a href=#{url}>#{number_with_code}</a>".html_safe
  end

  def itinerary_receipt
    if order && !new_record?
      url = show_order_for_ticket_path(order.pnr_number, self)
      "<a href=#{url}>билет</a>".html_safe
    end
  end

  def raw
    Strategy.select(:ticket => self).raw_ticket
  rescue => e
    e.message
  end
end
