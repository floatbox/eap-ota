ActiveAdmin.register Order do
  actions :all, except: [:destroy]

  scope :MOWR228FA
  scope :MOWR2233B
  scope :MOWR221F9
  scope :MOWR2219U
  scope :FLL1S212V
  scope :extra_pay
  scope :unticketed
  scope :processing_ticket
  scope :error_ticket
  scope :ticket_not_sent
  scope :sent_manual

  filter :pnr_number
  filter :parent_pnr_number
  filter :email
  filter :phone
  filter :created_at
  filter :source
  filter :payment_status
  filter :ticket_status
  filter :payment_type
  filter :has_refunds
  filter :partner

  index do
    column :source
    column :pnr_number
    column :blank_count
    column :contact
    column :created_at
    column :price_with_payment_commission
    column :payment_status
    column :ticket_status
    column :last_tkt_date
    column :payment_type_decorated, :payment_type
    column :has_refunds
    column :partner
    column :urgent
    actions
  end

  form do |f|
    f.inputs "section_general_info" do
      f.input :description
      f.input :has_refunds
      f.input :email
      f.input :phone
      f.input :source
      f.input :pnr_number
      f.input :parent_pnr_number
      f.input :sirena_lead_pass
      f.input :route
      f.input :payment_type
    end
    f.inputs "section_recalculation" do
      f.input :recalculation_alert
      f.input :commission_ticketing_method
      f.input :blank_count
      f.input :price_fare
      f.input :price_tax
      f.input :commission_agent
      f.input :commission_subagent
      f.input :commission_consolidator
      f.input :price_consolidator
      f.input :commission_blanks
      f.input :commission_discount
      f.input :commission_our_markup
      f.input :price_operational_fee
      f.input :pricing_method
      f.input :price_acquiring_compensation
      f.input :price_with_payment_commission
      f.input :price_difference
      f.input :commission_designator
      f.input :commission_tour_code
      f.input :fee_scheme
      f.input :fix_price
    end
    f.inputs "section_state_and_control" do
      f.input :ticket_status
      f.input :offline_booking
      f.input :last_pay_time
      f.input :needs_update_from_gds
      f.input :auto_ticket
    end
    f.actions
  end

  action_item :only => :show do
    link_to "History", :action => :history
  end
  member_action :history

end
