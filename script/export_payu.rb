#!/usr/bin/env ruby
require_relative '../config/environment'

require 'csv'
ActiveRecord::IdentityMap.enabled = true

DIR = 'tmp/'

def write_csv(filename, headers, collection)
  #CSV.open(DIR + filename, 'w', :col_sep => "\t") do |csv|
  CSV.open(DIR + filename, 'w') do |csv|
    csv << headers.map {|header| header.gsub('.', '_') }
    collection.each do |row|
      csv << headers.map {|header| header.split('.').inject(row, :send) rescue nil}
    end
  end
end


write_csv( 'payu.csv', %W[type ref their_ref price status created_at],
          Payment.where("type = 'PayuCharge' OR type = 'PayuRefund'").all );
