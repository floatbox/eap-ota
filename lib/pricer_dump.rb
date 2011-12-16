#!/usr/bin/env ruby
require File.expand_path('../../config/environment',  __FILE__)
require 'fileutils'

class PricerDump
  def self.create_dump
    FileUtils.touch 'log/pricer_dump.txt'
    File.open('log/pricer_dump.txt', 'w') do |f|
       PricerForm.all.each_with_index do |pf, i|
         from = pf.from_iata + ' '*(4-pf.from_iata.scan(/./u).length)
         to = pf.to_iata + ' '*(4-pf.to_iata.scan(/./u).length)
         f.puts ".\n" if i % 1000 == 0
         f.puts "#{from} #{to} #{pf.segments.first.date} #{pf.rt ? 'rt':'ow'}\n"
    end end
  end
end
PricerDump.create_dump