# encoding: utf-8

# документация колонок в таблице tickets
module TicketAttrs
    # !attribute source
    # @see Order#source
    # @return [String]

    # !attribute pnr_number
    # @see Order#pnr_number
    # @return [String]

    # !attribute number
    # @see number
    # @return [String]

    # !attribute price_fare
    # 
    # :precision => 9, :scale => 2, :default => 0.0,       :null => false
    # @return [Float]

    # !attribute commission_subagent
    # @see Commission::Rule#subagent
    # @return [String]

    # !attribute price_tax
    # @see Order#price_tax
    # :precision => 9, :scale => 2, :default => 0.0,       :null => false
    # @return [Float]

    # !attribute price_share
    # @deprecated сейчас не используется судя по всему
    # @see Order#price_share
    # :precision => 9, :scale => 2, :default => 0.0,       :null => false
    # @return [Float]

    # !attribute price_consolidator_markup
    # @see 
    # :precision => 9, :scale => 2, :default => 0.0,       :null => false
    # @return [Float]

    # !attribute order_id
    # @return [integer]

    # !attribute created_at
    # @return [DateTime]

    # !attribute updated_at
    # @return [DateTime]

    # !attribute cabins
    # @see Order#cabins
    # @return [String]

    # !attribute route
    # @see Order#route
    # @return [String]

    # !attribute first_name
    # Имя клиента и обращение в верхнем регистре, разделенные пробелом
    # @return [String]

    # !attribute last_name
    # Фамилия
    # @return [String]

    # !attribute passport
    #
    # @return [String]

    # !attribute code
    #
    # @return [String]

    # !attribute validator
    #
    # @return [String]

    # !attribute status
    #
    # @return [String]

    # !attribute office_id
    #
    # @return [String]

    # !attribute ticketed_Date
    #
    # @return [Date]

    # !attribute validating_carrier
    #
    # @return [String]

    # !attribute kind
    # :default => "ticket"
    # @return [String]

    # !attribute parent_id
    #
    # @return [integer]

    # !attribute price_penalty
    # :precision => 9, :scale => 2, :default => 0.0,       :null => false
    # @return [Float]

    # !attribute comment
    #
    # @return [text]

    # !attribute commission_agent
    #
    # @return [String]

    # !attribute commission_consolidator
    #
    # @return [String]

    # !attribute commission_blanks
    #
    # @return [String]

    # !attribute price_consolidator
    # :precision => 9, :scale => 2, :default => 0.0,       :null => false
    # @return [Float]

    # !attribute price_blanks
    # :precision => 9, :scale => 2, :default => 0.0,       :null => false
    # @return [Float]

    # !attribute price_agent
    # :precision => 9, :scale => 2, :default => 0.0,       :null => false
    # @return [Float]

    # !attribute price_subagent
    # :precision => 9, :scale => 2, :default => 0.0,       :null => false
    # @return [Float]

    # !attribute commission_discount
    #
    # @return [String]

    # !attribute price_discount
    # :precision => 9, :scale => 2, :default => 0.0,       :null => false
    # @return [Float]

    # !attribute mso_number
    #
    # @return [String]

    # !attribute corrected_price
    # :precision => 9, :scale => 2
    # @return [Float]

    # !attribute commission_our_markup
    #
    # @return [String]

    # !attribute price_our_markup
    # :precision => 9, :scale => 2, :default => 0.0,       :null => false
    # @return [Float]

    # !attribute vat_status
    # :default => "unknown", :null => false
    # @return [String]

    # !attribute dept_Date
    #
    # @return [Date]

    # !attribute price_extra_penalty
    # :precision => 9, :scale => 2, :default => 0.0,       :null => false
    # @return [Float]

    # !attribute baggage_info
    #
    # @return [String]

    # !attribute price_operational_fee
    # :precision => 9, :scale => 2, :default => 0.0,       :null => false
    # @return [Float]

    # !attribute price_acquiring_compensation
    # :precision => 9, :scale => 2, :default => 0.0,       :null => false
    # @return [Float]

    # !attribute price_difference
    # :precision => 9, :scale => 2, :default => 0.0,       :null => false
    # @return [Float]

end
