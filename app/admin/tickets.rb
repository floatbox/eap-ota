ActiveAdmin.register Ticket do
  actions :all, except: [:destroy]

  scope :uncomplete
  scope :sold

  filter :number
  filter :last_name
  filter :first_name
  filter :pnr_number

  filter :ticketed_date
  filter :dept_date
  filter :validating_carrier
  filter :source
  filter :validator
  filter :office_id
  filter :status
  filter :kind

  index do
    column :link_to_show
    column :order
    column :carrier
    column :name
    column :route
    column :price_fare
    column :price_tax
    column :customized_original_price_fare
    column :customized_original_price_tax
    column :rate
    column :office_id
    column :validator
    column :income_suppliers
    column :status
    column :kind
    column :ticketed_date
    column :dept_date
    column :itinerary_receipt
    column :parent
    actions
  end

  form do |f|
    f.inputs do
      f.input :code
      f.input :number
      f.input :status
      f.input :ticketed_date
      f.input :validating_carrier
      f.input :last_name
      f.input :first_name
      f.input :route
      f.input :original_price_fare_as_string
      f.input :original_price_tax_as_string
      f.input :original_price_penalty_as_string
      f.input :price_extra_penalty
      f.input :price_operational_fee
      f.input :price_acquiring_compensation
      f.input :price_difference
      f.input :commission_consolidator
      f.input :commission_blanks
      f.input :commission_agent
      f.input :commission_subagent
      f.input :commission_discount
      f.input :commission_our_markup
      f.input :price_acquiring_compensation
      f.input :office_id
      f.input :validator
      f.input :mso_number
      f.input :comment
      f.input :corrected_price
      f.input :cabins_joined
      f.input :booking_classes_joined
    end
    f.actions
  end

  action_item :only => :show do
    link_to "History", :action => :history
  end
  member_action :history

end
