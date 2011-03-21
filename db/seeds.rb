# FIXME csv-шки безбожно устарели
# вызывать нет смысла

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

require 'csv'

def import_aircrafts
  headers = nil

  Airplane.delete_all
  CSV.open('db/csv/airplanes.csv', 'r', ?,) do |row|
    unless headers
      headers = row.map(&:to_s)
      next
    end
    Airplane.create!( Hash[headers.zip(row.map(&:to_s))])
  end
end

def import_carriers
  headers = nil

  Carrier.delete_all
  CSV.open('db/csv/airlines.csv', 'r', ?,) do |row|
    unless headers
      headers = row.map(&:to_s)
      next
    end
    Carrier.create!( Hash[headers.zip(row.map(&:to_s))])
  end
end

import_aircrafts
import_carriers
