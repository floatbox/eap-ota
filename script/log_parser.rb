# encoding: utf-8
#!/usr/bin/env ruby

# Скрипт проверяет к каким валидным перевозчикам не применяются правила.

require_relative '../config/environment'

i ||= 0
carriers = {}

log_file = File.open('log/rec_shorter.log').each_line do |log_line_file|

  next if log_line_file =~ /^#/

  rec = Recommendation.example(log_line_file)

  begin
    if rec.commission.nil?
      i += 1
      carriers[rec.validating_carrier_iata] ||= 0
      carriers[rec.validating_carrier_iata] += 1
    end
  rescue IataStash::NotFound
    next
  end

end

puts ""
puts "---Скрипт проверяет к каким валидным перевозчикам не применяются правила---"
puts ""

carriers.each do |carrier, count|
  puts "К валид. перевозчику: #{carrier} не применяется правил: #{count}"
end

puts '--------------------------------------------------'

puts "Всего не применяется правил: #{i}"
puts ""