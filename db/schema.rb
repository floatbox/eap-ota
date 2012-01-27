# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120127034058) do

  create_table "airline_alliances", :force => true do |t|
    t.string "name",               :null => false
    t.string "bonus_program_name"
  end

  create_table "airplanes", :force => true do |t|
    t.string   "iata"
    t.string   "icao"
    t.string   "name_en"
    t.string   "name_ru"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "engine_type", :default => "jet"
    t.string   "iata_ru"
  end

  create_table "airports", :force => true do |t|
    t.string   "icao"
    t.string   "iata"
    t.string   "name_en"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "domestic"
    t.string   "name_ru"
    t.boolean  "federal"
    t.boolean  "international"
    t.integer  "runway_length"
    t.integer  "city_id"
    t.float    "lat"
    t.float    "lng"
    t.integer  "importance",    :default => 0, :null => false
    t.string   "synonym_list"
    t.string   "proper_to"
    t.string   "proper_from"
    t.string   "proper_in"
    t.string   "morpher_to"
    t.string   "morpher_from"
    t.string   "morpher_in"
    t.string   "iata_ru"
    t.string   "sirena_name"
    t.boolean  "disabled"
  end

  add_index "airports", ["iata"], :name => "index_airports_on_iata"
  add_index "airports", ["icao"], :name => "index_airports_on_icao"
  add_index "airports", ["name_en"], :name => "index_airports_on_name"

  create_table "amadeus_sessions", :force => true do |t|
    t.string   "token",                      :null => false
    t.integer  "seq",                        :null => false
    t.integer  "booking"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "office",     :default => "", :null => false
  end

  create_table "carriers", :force => true do |t|
    t.string   "en_shortname"
    t.string   "en_longname"
    t.string   "iata"
    t.string   "icao"
    t.string   "country_ru"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "country_id"
    t.string   "ru_shortname"
    t.string   "ru_longname"
    t.integer  "airline_alliance_id"
    t.string   "bonus_program_name"
    t.integer  "gds_id"
    t.integer  "consolidator_id"
    t.text     "interlines",          :null => false
    t.string   "color"
    t.string   "font_color"
    t.string   "iata_ru"
    t.text     "comment"
  end

  create_table "cities", :force => true do |t|
    t.string   "iata"
    t.string   "name_en"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name_ru"
    t.integer  "country_id"
    t.float    "lat"
    t.float    "lng"
    t.integer  "importance",    :default => 0,  :null => false
    t.string   "synonym_list"
    t.string   "proper_to"
    t.string   "proper_from"
    t.string   "proper_in"
    t.integer  "region_id"
    t.string   "timezone",      :default => ""
    t.string   "morpher_to"
    t.string   "morpher_from"
    t.string   "morpher_in"
    t.string   "iata_ru"
    t.string   "sirena_name"
    t.boolean  "disabled"
    t.boolean  "search_around"
  end

  add_index "cities", ["iata"], :name => "index_cities_on_iata"
  add_index "cities", ["name_en"], :name => "index_cities_on_name_en"
  add_index "cities", ["name_ru"], :name => "index_cities_on_name_ru"

  create_table "consolidators", :force => true do |t|
    t.string "name"
    t.string "booking_office"
    t.string "ticketing_office"
  end

  create_table "countries", :force => true do |t|
    t.string   "name_en"
    t.string   "name_ru"
    t.string   "full_name_ru"
    t.string   "alpha2"
    t.string   "alpha3"
    t.string   "iso"
    t.string   "continent"
    t.string   "continent_part_ru"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "importance",        :default => 0, :null => false
    t.string   "synonym_list"
    t.float    "lat"
    t.float    "lng"
    t.string   "proper_to"
    t.string   "proper_from"
    t.string   "proper_in"
    t.string   "morpher_to"
    t.string   "morpher_from"
    t.string   "morpher_in"
  end

  add_index "countries", ["alpha2"], :name => "index_countries_on_alpha2"
  add_index "countries", ["name_en"], :name => "index_countries_on_name_en"
  add_index "countries", ["name_ru"], :name => "index_countries_on_name_ru"

  create_table "destinations", :force => true do |t|
    t.integer  "to_id"
    t.integer  "from_id"
    t.boolean  "rt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "average_price"
    t.integer  "average_time_delta"
    t.integer  "hot_offers_counter", :default => 0
  end

  create_table "flight_groups", :force => true do |t|
    t.text     "code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "source",     :null => false
  end

  create_table "geo_taggings", :force => true do |t|
    t.integer  "geo_tag_id"
    t.integer  "location_id"
    t.string   "location_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "geo_tags", :force => true do |t|
    t.string   "name"
    t.string   "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "importance",   :default => 0, :null => false
    t.string   "synonym_list"
    t.string   "proper_to"
    t.string   "proper_from"
    t.string   "proper_in"
    t.float    "lat"
    t.float    "lng"
  end

  create_table "global_distribution_systems", :force => true do |t|
    t.string "name"
  end

  create_table "hot_offers", :force => true do |t|
    t.string   "code",                    :null => false
    t.string   "url",                     :null => false
    t.string   "description",             :null => false
    t.integer  "price",                   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "for_stats_only"
    t.integer  "destination_id"
    t.integer  "time_delta"
    t.integer  "price_variation"
    t.integer  "price_variation_percent"
    t.date     "date1"
    t.date     "date2"
  end

  add_index "hot_offers", ["created_at"], :name => "index_hot_offers_on_created_at"
  add_index "hot_offers", ["destination_id"], :name => "index_hot_offers_on_destination_id"

  create_table "notifications", :force => true do |t|
    t.integer  "order_id"
    t.integer  "typus_user_id"
    t.integer  "ticket_id"
    t.string   "pnr_number"
    t.boolean  "attach_pnr",       :default => true
    t.string   "status",           :default => "",      :null => false
    t.string   "method",           :default => "email", :null => false
    t.string   "destination"
    t.text     "comment"
    t.datetime "activate_from"
    t.datetime "sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "subject"
    t.string   "format"
    t.text     "rendered_message"
  end

  create_table "order_comments", :force => true do |t|
    t.integer  "order_id"
    t.integer  "typus_user_id"
    t.text     "text",           :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "assigned_to_id"
    t.string   "status"
    t.integer  "priority"
  end

  create_table "orders", :force => true do |t|
    t.string   "email"
    t.string   "phone"
    t.string   "pnr_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "commission_carrier"
    t.string   "commission_agent"
    t.string   "commission_subagent"
    t.decimal  "price_share",                   :precision => 9, :scale => 2, :default => 0.0,      :null => false
    t.decimal  "price_our_markup",              :precision => 9, :scale => 2, :default => 0.0,      :null => false
    t.decimal  "price_with_payment_commission", :precision => 9, :scale => 2, :default => 0.0,      :null => false
    t.string   "order_id"
    t.string   "full_info"
    t.string   "payment_status",                                              :default => "new"
    t.decimal  "price_fare",                    :precision => 9, :scale => 2, :default => 0.0,      :null => false
    t.string   "ticket_status",                                               :default => "booked"
    t.decimal  "price_consolidator_markup",     :precision => 9, :scale => 2, :default => 0.0,      :null => false
    t.string   "name_in_card"
    t.string   "last_digits_in_card"
    t.text     "commission_agent_comments",                                                         :null => false
    t.text     "commission_subagent_comments",                                                      :null => false
    t.string   "source",                                                      :default => "other"
    t.string   "sirena_lead_pass"
    t.string   "code"
    t.string   "description"
    t.date     "last_tkt_date"
    t.date     "ticketed_date"
    t.text     "delivery"
    t.string   "payment_type"
    t.datetime "last_pay_time"
    t.decimal  "cash_payment_markup",           :precision => 9, :scale => 2, :default => 0.0,      :null => false
    t.string   "cabins"
    t.decimal  "price_difference",              :precision => 9, :scale => 2, :default => 0.0,      :null => false
    t.boolean  "offline_booking",                                             :default => false,    :null => false
    t.string   "email_status",                                                :default => "",       :null => false
    t.string   "route"
    t.decimal  "price_tax",                     :precision => 9, :scale => 2, :default => 0.0,      :null => false
    t.date     "departure_date"
    t.integer  "blank_count"
    t.string   "partner"
    t.boolean  "has_refunds",                                                 :default => false,    :null => false
    t.string   "pricing_method",                                              :default => "",       :null => false
    t.string   "commission_consolidator"
    t.string   "commission_discount"
    t.decimal  "price_discount",                :precision => 9, :scale => 2, :default => 0.0,      :null => false
    t.string   "commission_blanks"
    t.decimal  "price_consolidator",            :precision => 9, :scale => 2, :default => 0.0,      :null => false
    t.decimal  "price_blanks",                  :precision => 9, :scale => 2, :default => 0.0,      :null => false
    t.decimal  "price_agent",                   :precision => 9, :scale => 2, :default => 0.0,      :null => false
    t.decimal  "price_subagent",                :precision => 9, :scale => 2, :default => 0.0,      :null => false
    t.string   "commission_ticketing_method",                                 :default => "",       :null => false
    t.boolean  "fix_price",                                                   :default => false,    :null => false
    t.boolean  "old_booking",                                                 :default => false,    :null => false
    t.string   "pan"
    t.string   "marker"
    t.string   "commission_our_markup"
  end

  create_table "payments", :force => true do |t|
    t.decimal  "price",                 :precision => 9, :scale => 2, :default => 0.0, :null => false
    t.string   "last_digits_in_card"
    t.string   "name_in_card"
    t.string   "payment_system_name"
    t.string   "payment_status"
    t.integer  "transaction_id"
    t.integer  "refund_transaction_id"
    t.integer  "order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "reject_reason"
    t.string   "ref"
    t.datetime "charged_at"
    t.string   "threeds_key"
    t.string   "system"
    t.date     "charged_on"
    t.string   "pan"
  end

  create_table "regions", :force => true do |t|
    t.string   "name_en"
    t.string   "name_ru"
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "morpher_to"
    t.string   "morpher_from"
    t.string   "morpher_in"
    t.string   "proper_to"
    t.string   "proper_from"
    t.string   "proper_in"
    t.float    "lat"
    t.float    "lng"
    t.integer  "importance",   :default => 0
    t.string   "region_type"
    t.string   "synonym_list"
  end

  create_table "subscriptions", :force => true do |t|
    t.integer  "destination_id",                 :null => false
    t.string   "email",                          :null => false
    t.string   "status",         :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "from_iata"
    t.string   "to_iata"
    t.boolean  "rt"
  end

  add_index "subscriptions", ["destination_id"], :name => "index_subscriptions_on_destination_id"

  create_table "tickets", :force => true do |t|
    t.string   "source"
    t.string   "pnr_number"
    t.string   "number"
    t.decimal  "price_fare",                :precision => 9, :scale => 2, :default => 0.0,      :null => false
    t.string   "commission_subagent"
    t.decimal  "price_tax",                 :precision => 9, :scale => 2, :default => 0.0,      :null => false
    t.decimal  "price_share",               :precision => 9, :scale => 2, :default => 0.0,      :null => false
    t.decimal  "price_consolidator_markup", :precision => 9, :scale => 2, :default => 0.0,      :null => false
    t.integer  "order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cabins"
    t.string   "route"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "passport"
    t.string   "code"
    t.string   "validator"
    t.string   "status"
    t.string   "office_id"
    t.date     "ticketed_date"
    t.string   "validating_carrier"
    t.string   "kind",                                                    :default => "ticket"
    t.boolean  "processed",                                               :default => false
    t.integer  "parent_id"
    t.decimal  "price_penalty",             :precision => 9, :scale => 2, :default => 0.0,      :null => false
    t.text     "comment"
    t.string   "commission_agent"
    t.string   "commission_consolidator"
    t.string   "commission_blanks"
    t.decimal  "price_consolidator",        :precision => 9, :scale => 2, :default => 0.0,      :null => false
    t.decimal  "price_blanks",              :precision => 9, :scale => 2, :default => 0.0,      :null => false
    t.decimal  "price_agent",               :precision => 9, :scale => 2, :default => 0.0,      :null => false
    t.decimal  "price_subagent",            :precision => 9, :scale => 2, :default => 0.0,      :null => false
    t.string   "commission_discount"
    t.decimal  "price_discount",            :precision => 9, :scale => 2, :default => 0.0,      :null => false
    t.string   "mso_number"
    t.decimal  "corrected_price",           :precision => 9, :scale => 2
    t.string   "commission_our_markup"
    t.decimal  "price_our_markup",          :precision => 9, :scale => 2, :default => 0.0,      :null => false
  end

  create_table "typus_users", :force => true do |t|
    t.string   "first_name",       :default => "",    :null => false
    t.string   "last_name",        :default => "",    :null => false
    t.string   "role",                                :null => false
    t.string   "email",                               :null => false
    t.boolean  "status",           :default => false
    t.string   "token",                               :null => false
    t.string   "salt",                                :null => false
    t.string   "crypted_password",                    :null => false
    t.string   "preferences"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "versions", :force => true do |t|
    t.string   "item_type",      :null => false
    t.integer  "item_id",        :null => false
    t.string   "event",          :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

end
