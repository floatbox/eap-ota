#!/usr/bin/env ruby
# encoding: utf-8

# Скрипт проверяет к каким валидным перевозчикам не применяются правила.

require_relative '../config/environment'

filename = ARGV.first || 'log/rec_short.log'

i ||= 0
carriers = {}
totals = {}

log_file = File.open(filename).each_line do |log_line_file|

  next if log_line_file =~ /^#/

  rec = Recommendation.example(log_line_file)

  carrier = rec.validating_carrier_iata
  totals[carrier] ||= 0
  totals[carrier] += 1
  begin
    if rec.commission.nil?
      i += 1
      carriers[carrier] ||= 0
      carriers[carrier] += 1
    end
  rescue IataStash::NotFound
    next
  end

end

puts ""
puts "---Скрипт проверяет к каким валидным перевозчикам не применяются правила---"
puts ""

carriers.each do |carrier, count|
  total = totals[carrier]
  percentage = (count.to_f / total * 100).round(2)
  puts "К валид. перевозчику: #{carrier} не применяется правил: #{percentage}% (#{count}/#{total})"
end

puts '--------------------------------------------------'

puts "Всего не применяется правил: #{i}"
puts ""
