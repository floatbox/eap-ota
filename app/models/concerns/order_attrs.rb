# encoding: utf-8

# просто документация колонок в таблице orders
module OrderAttrs

  # @!attribute email
  #   @return [String]

  # @!attribute phone
  #   @return [String]

  # @!attribute pnr_number
  #   @return [String]

  # @!attribute created_at
  #   @return [DateTime]

  # @!attribute updated_at
  #   @return [DateTime]

  # @!attribute commission_carrier
  #   @return [String]

  # @!attribute commission_agent
  #   @return [String]

  # @!attribute commission_subagent
  #   @return [String]

  # @!attribute price_share
  #   @return [BigDecimal]    :default => 0.0,      :null => false

  # @!attribute price_our_markup
  #   @return [BigDecimal]    :default => 0.0,      :null => false

  # @!attribute price_with_payment_commission
  #   @return [BigDecimal]    :default => 0.0,      :null => false

  # @!attribute order_id
  #   @return [String]

  # @!attribute full_info
  #   @return [String]

  # @!attribute payment_status
  #   @return [String]          :default => "new"

  # @!attribute price_fare
  #   @return [BigDecimal]   :default => 0.0,      :null => false

  # @!attribute ticket_status
  #   @return [String]          :default => "booked"

  # @!attribute price_consolidator_markup
  #   @return [BigDecimal]   :default => 0.0,      :null => false

  # @!attribute name_in_card
  #   @return [String]

  # @!attribute last_digits_in_card
  #   @return [String]

  # @!attribute commission_agent_comments
  #   @return [Text]            :null => false

  # @!attribute commission_subagent_comments
  #   @return [Text]            :null => false

  # @!attribute source
  #   @return [String]          :default => "other"

  # @!attribute sirena_lead_pass
  #   @return [String]

  # @!attribute code
  #   @return [String]

  # @!attribute description
  #   @return [String]

  # @!attribute last_tkt_date
  #   @return [Date]

  # @!attribute ticketed_date
  #   @return [Date]

  # @!attribute delivery
  #   @return [Text]

  # @!attribute payment_type
  #   @return [String]

  # @!attribute last_pay_time
  #   @return [DateTime]

  # @!attribute cash_payment_markup
  #   @return [BigDecimal]   :default => 0.0,      :null => false

  # @!attribute cabins
  #   @return [String]

  # @!attribute price_difference
  #   @return [BigDecimal]   :default => 0.0,      :null => false

  # @!attribute offline_booking
  #   @return [Boolean]         :default => false,    :null => false

  # @!attribute email_status
  #   @return [String]          :default => "",       :null => false

  # @!attribute route
  #   @return [String]

  # @!attribute price_tax
  #   @return [BigDecimal]   :default => 0.0,      :null => false

  # @!attribute departure_date
  #   @return [Date]

  # @!attribute blank_count
  #   @return [Fixnum]

  # @!attribute partner
  #   @return [String]

  # @!attribute has_refunds
  #   @return [Boolean]                                    :default => false,    :null => false

  # @!attribute pricing_method
  #   @return [String]                                     :default => "",       :null => false

  # @!attribute commission_consolidator
  #   @return [String]

  # @!attribute commission_discount
  #   @return [String]

  # @!attribute price_discount
  #   @return [BigDecimal]   :default => 0.0,      :null => false

  # @!attribute commission_blanks
  #   @return [String]

  # @!attribute price_consolidator
  #   @return [BigDecimal]   :default => 0.0,      :null => false

  # @!attribute price_blanks
  #   @return [BigDecimal]   :default => 0.0,      :null => false

  # @!attribute price_agent
  #   @return [BigDecimal]   :default => 0.0,      :null => false

  # @!attribute price_subagent
  #   @return [BigDecimal]   :default => 0.0,      :null => false

  # @!attribute commission_ticketing_method
  #   @return [String]          :default => "",       :null => false

  # @!attribute fix_price
  #   @return [Boolean]         :default => false,    :null => false

  # @!attribute old_booking
  #   @return [Boolean]         :default => false,    :null => false

  # @!attribute pan
  #   @return [String]

  # @!attribute marker
  #   @return [String]

  # @!attribute commission_our_markup
  #   @return [String]

  # @!attribute parent_pnr_number
  #   @return [String]

  # @!attribute stored_income
  #   @return [BigDecimal]    :default => 0.0,      :null => false

  # @!attribute stored_balance
  #   @return [BigDecimal]    :default => 0.0,      :null => false

  # @!attribute customer_id
  #   @return [Fixnum]

  # @!attribute price_operational_fee
  #   @return [BigDecimal]    :default => 0.0,      :null => false

  # @!attribute fee_scheme
  #   @return [String]        :default => ""

  # @!attribute price_acquiring_compensation
  #   @return [BigDecimal]    :default => 0.0,      :null => false

  # @!attribute commission_tour_code
  #   @return [String]

  # @!attribute commission_designator
  #   @return [String]

end
