class Initial < ActiveRecord::Migration
  def self.up
    create_table "airlines", :force => true do |t|
      t.string   "en_shortname"
      t.string   "iata"
      t.string   "country_ru"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "country_id"
      t.string   "en_longname"
      t.string   "ru_shortname"
      t.string   "ru_longname"
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
    end

    add_index "airports", ["iata"], :name => "index_airports_on_iata"
    add_index "airports", ["icao"], :name => "index_airports_on_icao"
    add_index "airports", ["name_en"], :name => "index_airports_on_name"

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
    end

    add_index "cities", ["iata"], :name => "index_cities_on_iata"
    add_index "cities", ["name_en"], :name => "index_cities_on_name_en"
    add_index "cities", ["name_ru"], :name => "index_cities_on_name_ru"

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

    create_table "interline_agreements", :id => false, :force => true do |t|
      t.integer "company_id", :null => false
      t.integer "partner_id", :null => false
    end

    create_table "orders", :force => true do |t|
      t.string   "email"
      t.string   "first_name"
      t.string   "surname"
      t.string   "phone"
      t.string   "pnr_number"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "presets", :force => true do |t|
      t.string   "name"
      t.text     "query"
      t.datetime "created_at"
      t.datetime "updated_at"
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

  def self.down
  end
end
