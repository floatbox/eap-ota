#!/usr/bin/env ruby
require File.expand_path('../../config/environment',  __FILE__)
require 'fileutils'

class PricerDump
  def self.create_dump
    FileUtils.touch 'log/pricer_dump.txt'
    File.open('log/pricer_dump.txt', 'w') do |f|
       PricerForm.all.desc(:created_at).each_with_index do |pf, i|
         begin
         if pf.from_iata.present? && pf.to_iata.present?
           print "." if i % 100 == 0
           puts i if i % 5000 == 0 && i != 0
           STDIN.flush

           from = pf.from_iata + ' '*(4-pf.from_iata.scan(/./u).length)
           to = pf.to_iata + ' '*(4-pf.to_iata.scan(/./u).length)
           f.puts "#{from} #{to} #{pf.segments.first.date_as_date.to_s} #{pf.rt ? 'rt':'ow'} #{pf.adults} #{pf.children} #{pf.infants} #{pf.created_at.to_date.to_s} #{pf.partner}"
         end
         rescue
           puts $!
         end
      end
    end
  end
end
PricerDump.create_dump
