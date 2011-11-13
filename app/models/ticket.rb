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
  has_one :refund, :class_name => 'Ticket', :foreign_key => 'parent_id'

  delegate :source, :pnr_number, :need_attention, :paid_by, :to => :order

  delegate :commission_carrier, :to => :order, :allow_nil => true

  extend Commission::Columns
  has_commission_columns :commission_agent, :commission_subagent, :commission_consolidator, :commission_blanks, :commission_discount
  include PricingMethods::Ticket

  before_save :copy_commissions_from_order
  before_save :recalculate_commissions

  scope :uncomplete, where(:ticketed_date => nil)

  before_create :set_refund_data, :if => lambda {kind == "refund"}
  validate :check_uniqueness_of_refund
  validates_presence_of :comment, :if => lambda {kind == "refund"}
  after_save :update_prices_in_order

  # FIXME сделать перечисление прямо из базы, через uniq
  def self.office_ids
    ['MOWR2233B', 'MOWR228FA', 'MOWR2219U']
  end

  def self.validators
    ['92223412', '92228065']
  end

  def self.sources
    ['amadeus', 'sirena']
  end

  def self.statuses
    ['ticketed', 'voided', 'pending']
  end

  def self.ensure_exists number
    raise ArgumentError, 'ticket number is blank' if number.blank?
    find_or_initialize_by_number number
  end

  def update_prices_in_order
    order.tickets.reload if order
    order.update_prices_from_tickets if order
  end

  def check_uniqueness_of_refund
    errors.add :refund, 'для данного билета уже существует' if kind == 'refund' && new_record? && Ticket.where(:parent_id => parent.id).count > 0
  end

  def set_refund_data
    copy_attrs parent, self,
      :validator,
      :office_id,
      :first_name,
      :last_name,
      :passport,
      :pnr_number,
      :order,
      :code,
      :number,
      :source
  end

  def copy_commissions_from_order
    return unless order
    for attr in [ :commission_agent, :commission_subagent, :commission_consolidator, :commission_blanks, :commission_discount ]
      if send(attr).nil?
        send("#{attr}=", order.send(attr))
      end
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
    if kind == 'ticket' && refund.blank?
      "<a href='/admin/tickets/new_refund?_popup=true&&resource[kind]=refund&resource[parent_id]=#{id}' class='iframe'>Add refund</a>".html_safe
    end
  end

  def first_number_with_code
    "#{code}-#{first_number}" if number.present?
  end

  def name
    "#{last_name} #{first_name}"
  end

  def carrier
    validating_carrier || commission_carrier
  end

  # для тайпуса
  def description
    if kind == 'ticket'
      (
      "Билет  № #{number_with_code} <br>" +
        if self.refund
          "есть #{!refund.processed ? 'неподтвержденный клиентом' : ''} возврат "
        else
          "<a href='/admin/tickets/new_refund?_popup=true&&resource[kind]=refund&resource[parent_id]=#{id}' class='iframe'>Добавить возврат</a>"
        end

      ).html_safe
    elsif kind == 'refund'
      (
      "Возврат для билета № #{number_with_code} <br>" +
      "Сумма к возварату: #{price_refund} рублей"
      ).html_safe
    end
  end

  # для админки
  def to_label
    "#{source} #{number} #{route} #{updated_at}"
  end

  def itinerary_receipt
    if order && !new_record?
      url = show_order_for_ticket_path(order.pnr_number, self)
      "<a href=#{url}>билет</a>".html_safe
    end
  end

  def raw # FIXME в стратегию
    Strategy.new(:source => 'amadeus', :ticket => self).raw_ticket
  rescue => e
    e.message
  end
end
