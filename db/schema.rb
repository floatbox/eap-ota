# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20131126160754) do

  create_table "active_admin_comments", :force => true do |t|
    t.string   "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

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
    t.boolean  "auto_save",   :default => false, :null => false
  end

  add_index "airplanes", ["iata"], :name => "index_airplanes_on_iata"

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
    t.integer  "importance",    :default => 0,     :null => false
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
    t.boolean  "auto_save",     :default => false, :null => false
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
    t.text     "interlines",          :null => false
    t.string   "color"
    t.string   "font_color"
    t.string   "iata_ru"
    t.text     "comment"
    t.string   "code"
    t.string   "not_interlines"
  end

  add_index "carriers", ["iata"], :name => "index_carriers_on_iata"

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
    t.string   "ufi"
  end

  add_index "cities", ["iata"], :name => "index_cities_on_iata"
  add_index "cities", ["lat", "lng"], :name => "index_cities_on_lat_and_lng"
  add_index "cities", ["name_en"], :name => "index_cities_on_name_en"
  add_index "cities", ["name_ru"], :name => "index_cities_on_name_ru"

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

  create_table "currency_rates", :force => true do |t|
    t.string   "from"
    t.string   "to"
    t.string   "bank"
    t.float    "rate"
    t.date     "date"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "customer_instructions", :force => true do |t|
    t.string   "status"
    t.string   "email"
    t.string   "format"
    t.string   "subject"
    t.text     "message"
    t.integer  "customer_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "customer_instructions", ["customer_id"], :name => "index_customer_instructions_on_customer_id"

  create_table "customers", :force => true do |t|
    t.string   "email",                                                    :null => false
    t.string   "password"
    t.string   "status"
    t.boolean  "enabled",                               :default => false, :null => false
    t.datetime "created_at",                                               :null => false
    t.datetime "updated_at",                                               :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
  end

  add_index "customers", ["confirmation_token"], :name => "index_customers_on_confirmation_token", :unique => true
  add_index "customers", ["email"], :name => "index_customers_on_email", :unique => true
  add_index "customers", ["reset_password_token"], :name => "index_customers_on_reset_password_token", :unique => true

  create_table "deck_users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "first_name",             :default => "", :null => false
    t.string   "last_name",              :default => "", :null => false
    t.datetime "locked_at"
    t.string   "roles",                  :default => "", :null => false
  end

  add_index "deck_users", ["email"], :name => "index_deck_users_on_email", :unique => true
  add_index "deck_users", ["reset_password_token"], :name => "index_deck_users_on_reset_password_token", :unique => true

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

  create_table "fare_rules", :force => true do |t|
    t.string   "carrier"
    t.string   "fare_base"
    t.string   "to_iata"
    t.string   "from_iata"
    t.string   "passenger_type"
    t.text     "rule_text"
    t.integer  "order_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "fare_rules", ["order_id"], :name => "index_fare_rules_on_order_id"

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

  create_table "imports", :force => true do |t|
    t.string   "md5"
    t.string   "kind"
    t.integer  "pass"
    t.string   "filename"
    t.binary   "content"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "imports", ["md5"], :name => "index_imports_on_md5", :unique => true

  create_table "imports_payments", :id => false, :force => true do |t|
    t.integer "import_id"
    t.integer "payment_id"
  end

  add_index "imports_payments", ["import_id", "payment_id"], :name => "index_imports_payments_on_import_id_and_payment_id"

  create_table "imports_tickets", :id => false, :force => true do |t|
    t.integer "import_id"
    t.integer "ticket_id"
  end

  add_index "imports_tickets", ["import_id", "ticket_id"], :name => "index_imports_tickets_on_import_id_and_ticket_id"

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
    t.string   "lang"
  end

  add_index "notifications", ["method", "status"], :name => "index_notifications_on_method_and_status"
  add_index "notifications", ["order_id"], :name => "index_notifications_on_order_id"

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

  create_table "order_requests", :force => true do |t|
    t.integer  "order_id"
    t.integer  "assigned_to_id"
    t.string   "status"
    t.string   "subject"
    t.text     "message",        :null => false
    t.text     "comment"
    t.integer  "priority"
    t.date     "departure_date"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "order_requests", ["assigned_to_id"], :name => "index_order_requests_on_assigned_to_id"
  add_index "order_requests", ["departure_date"], :name => "index_order_requests_on_departure_date"
  add_index "order_requests", ["order_id"], :name => "index_order_requests_on_order_id"
  add_index "order_requests", ["priority"], :name => "index_order_requests_on_priority"

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
    t.string   "commission_agent_comments",                                   :default => ""
    t.string   "commission_subagent_comments",                                :default => ""
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
    t.string   "parent_pnr_number"
    t.decimal  "stored_income",                 :precision => 9, :scale => 2, :default => 0.0,      :null => false
    t.decimal  "stored_balance",                :precision => 9, :scale => 2, :default => 0.0,      :null => false
    t.integer  "customer_id"
    t.decimal  "price_operational_fee",         :precision => 9, :scale => 2, :default => 0.0,      :null => false
    t.string   "fee_scheme",                                                  :default => ""
    t.decimal  "price_acquiring_compensation",  :precision => 9, :scale => 2, :default => 0.0,      :null => false
    t.string   "commission_tour_code"
    t.string   "commission_designator"
    t.boolean  "auto_ticket",                                                 :default => false
    t.string   "no_auto_ticket_reason",                                       :default => ""
    t.string   "additional_pnr_number"
    t.boolean  "needs_visa_notification",                                     :default => false
    t.boolean  "old_downtown_booking",                                        :default => false
  end

  add_index "orders", ["customer_id"], :name => "index_orders_on_customer_id"
  add_index "orders", ["partner"], :name => "index_orders_on_partner"
  add_index "orders", ["payment_status", "ticket_status"], :name => "index_orders_on_payment_status_and_ticket_status"
  add_index "orders", ["payment_status"], :name => "index_orders_on_payment_status"
  add_index "orders", ["payment_type"], :name => "index_orders_on_payment_type"
  add_index "orders", ["pnr_number"], :name => "index_orders_on_pnr_number"
  add_index "orders", ["ticket_status"], :name => "index_orders_on_ticket_status"

  create_table "orders_stored_flights", :id => false, :force => true do |t|
    t.integer "stored_flight_id"
    t.integer "order_id"
  end

  add_index "orders_stored_flights", ["order_id", "stored_flight_id"], :name => "index_orders_stored_flights_on_order_id_and_stored_flight_id"
  add_index "orders_stored_flights", ["stored_flight_id", "order_id"], :name => "index_orders_stored_flights_on_stored_flight_id_and_order_id"

  create_table "partners", :force => true do |t|
    t.string   "token",                                  :null => false
    t.string   "password",                               :null => false
    t.boolean  "enabled",                                :null => false
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.boolean  "hide_income",                            :null => false
    t.integer  "cookies_expiry_time"
    t.integer  "income_at_least"
    t.integer  "suggested_limit"
    t.boolean  "cheat",               :default => false
    t.text     "notes"
    t.string   "cheat_mode",          :default => "no"
  end

  add_index "partners", ["token"], :name => "index_partners_on_token"

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
    t.string   "type"
    t.integer  "charge_id"
    t.string   "status"
    t.string   "commission"
    t.decimal  "earnings",              :precision => 9, :scale => 2, :default => 0.0, :null => false
    t.string   "their_ref"
    t.string   "error_code"
    t.text     "error_message"
    t.string   "endpoint_name",                                       :default => ""
  end

  add_index "payments", ["order_id"], :name => "index_payments_on_order_id"
  add_index "payments", ["pan"], :name => "index_payments_on_pan"
  add_index "payments", ["status"], :name => "index_payments_on_status"

  create_table "promo_codes", :force => true do |t|
    t.string   "code",                           :null => false
    t.boolean  "used",        :default => false
    t.integer  "order_id"
    t.string   "value"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.date     "valid_until",                    :null => false
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

  create_table "stored_flights", :force => true do |t|
    t.string   "departure_iata",         :limit => 3
    t.string   "arrival_iata",           :limit => 3
    t.string   "departure_term",         :limit => 1
    t.string   "arrival_term",           :limit => 1
    t.string   "marketing_carrier_iata", :limit => 2
    t.string   "operating_carrier_iata", :limit => 2
    t.string   "flight_number",          :limit => 5
    t.date     "dept_date"
    t.string   "departure_time",         :limit => 4
    t.date     "arrv_date"
    t.string   "arrival_time",           :limit => 4
    t.string   "equipment_type_iata",    :limit => 4
    t.integer  "technical_stop_count"
    t.integer  "duration"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  add_index "stored_flights", ["marketing_carrier_iata", "flight_number", "departure_iata", "arrival_iata", "dept_date"], :name => "index_stored_flights", :unique => true

  create_table "stored_flights_tickets", :id => false, :force => true do |t|
    t.integer "stored_flight_id"
    t.integer "ticket_id"
  end

  add_index "stored_flights_tickets", ["stored_flight_id", "ticket_id"], :name => "index_stored_flights_tickets_on_stored_flight_id_and_ticket_id"

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
    t.decimal  "price_fare",                                   :precision => 9, :scale => 2, :default => 0.0,       :null => false
    t.string   "commission_subagent"
    t.decimal  "price_tax",                                    :precision => 9, :scale => 2, :default => 0.0,       :null => false
    t.decimal  "price_share",                                  :precision => 9, :scale => 2, :default => 0.0,       :null => false
    t.decimal  "price_consolidator_markup",                    :precision => 9, :scale => 2, :default => 0.0,       :null => false
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
    t.string   "kind",                                                                       :default => "ticket"
    t.integer  "parent_id"
    t.decimal  "price_penalty",                                :precision => 9, :scale => 2, :default => 0.0,       :null => false
    t.text     "comment"
    t.string   "commission_agent"
    t.string   "commission_consolidator"
    t.string   "commission_blanks"
    t.decimal  "price_consolidator",                           :precision => 9, :scale => 2, :default => 0.0,       :null => false
    t.decimal  "price_blanks",                                 :precision => 9, :scale => 2, :default => 0.0,       :null => false
    t.decimal  "price_agent",                                  :precision => 9, :scale => 2, :default => 0.0,       :null => false
    t.decimal  "price_subagent",                               :precision => 9, :scale => 2, :default => 0.0,       :null => false
    t.string   "commission_discount"
    t.decimal  "price_discount",                               :precision => 9, :scale => 2, :default => 0.0,       :null => false
    t.string   "mso_number"
    t.decimal  "corrected_price",                              :precision => 9, :scale => 2
    t.string   "commission_our_markup"
    t.decimal  "price_our_markup",                             :precision => 9, :scale => 2, :default => 0.0,       :null => false
    t.string   "vat_status",                                                                 :default => "unknown", :null => false
    t.date     "dept_date"
    t.decimal  "price_extra_penalty",                          :precision => 9, :scale => 2, :default => 0.0,       :null => false
    t.string   "baggage_info"
    t.decimal  "price_operational_fee",                        :precision => 9, :scale => 2, :default => 0.0,       :null => false
    t.decimal  "price_acquiring_compensation",                 :precision => 9, :scale => 2, :default => 0.0,       :null => false
    t.decimal  "price_difference",                             :precision => 9, :scale => 2, :default => 0.0,       :null => false
    t.string   "additional_pnr_number"
    t.integer  "original_price_fare_cents"
    t.string   "original_price_fare_currency",    :limit => 3
    t.integer  "original_price_tax_cents"
    t.string   "original_price_tax_currency",     :limit => 3
    t.integer  "original_price_penalty_cents"
    t.string   "original_price_penalty_currency", :limit => 3
    t.string   "booking_classes"
  end

  add_index "tickets", ["kind"], :name => "index_tickets_on_kind"
  add_index "tickets", ["office_id"], :name => "index_tickets_on_office_id"
  add_index "tickets", ["order_id"], :name => "index_tickets_on_order_id"
  add_index "tickets", ["parent_id"], :name => "index_tickets_on_parent_id"
  add_index "tickets", ["pnr_number"], :name => "index_tickets_on_pnr_number"
  add_index "tickets", ["status"], :name => "index_tickets_on_status"

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
    t.string   "done"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

end
