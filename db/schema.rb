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

ActiveRecord::Schema.define(:version => 20110219174249) do

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
    t.integer  "importance",   :default => 0,  :null => false
    t.string   "synonym_list"
    t.string   "proper_to"
    t.string   "proper_from"
    t.string   "proper_in"
    t.integer  "region_id"
    t.string   "timezone",     :default => ""
    t.string   "morpher_to"
    t.string   "morpher_from"
    t.string   "morpher_in"
    t.string   "iata_ru"
    t.string   "sirena_name"
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
    t.string   "continent_ru"
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
    t.string   "code",           :null => false
    t.string   "url",            :null => false
    t.string   "description",    :null => false
    t.integer  "price",          :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "for_stats_only"
  end

  create_table "orders", :force => true do |t|
    t.string   "email"
    t.string   "phone"
    t.string   "pnr_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "price_total",                   :precision => 9, :scale => 2, :default => 0.0, :null => false
    t.string   "commission_carrier"
    t.string   "commission_agent"
    t.string   "commission_subagent"
    t.decimal  "price_share",                   :precision => 9, :scale => 2, :default => 0.0, :null => false
    t.decimal  "price_our_markup",              :precision => 9, :scale => 2, :default => 0.0, :null => false
    t.decimal  "price_with_payment_commission", :precision => 9, :scale => 2, :default => 0.0, :null => false
    t.string   "order_id"
    t.string   "full_info"
    t.string   "payment_status"
    t.decimal  "price_fare",                    :precision => 9, :scale => 2, :default => 0.0, :null => false
    t.decimal  "price_tax",                     :precision => 9, :scale => 2, :default => 0.0, :null => false
    t.string   "ticket_status"
    t.decimal  "price_consolidator_markup",     :precision => 9, :scale => 2, :default => 0.0, :null => false
    t.string   "name_in_card"
    t.string   "last_digits_in_card"
  end

  create_table "regions", :force => true do |t|
    t.string   "name_en"
    t.string   "name_ru"
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
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

end
