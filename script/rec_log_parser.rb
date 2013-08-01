#!/usr/bin/env ruby
# encoding: utf-8

# Скрипт проверяет к каким валидным перевозчикам не применяются правила.

$opts = {
  interactive: false
}
require_relative '../config/environment'

filename = ARGV.first || 'log/rec_short.log'
warn "starting..."

totals = {}
unsellables = {}
total_recs = 0
unsellable_recs = 0

trap :INT do
  exit
end

at_exit do
  totals.keys.sort.each do |carrier|
    total = totals[carrier]
    unsellable = unsellables[carrier] || 0
    percentage = (unsellable.to_f / total * 100).round(2)
    if $opts[:interactive]
      puts "#{carrier}: #{'%6.2f' % percentage}%  (#{unsellable}/#{total})"
    else
      puts [carrier, '%.2f' % percentage, unsellable, total].map(&:to_s).join("\t")
    end
  end
  if $opts[:interactive]
    puts
    puts "total recs: #{total_recs}"
    puts "unsellable recs: #{unsellable_recs}"
  end
end

# заглушка вместо нормального nex3-ruby-progressbar
class Progressbar
  def initialize(*)
    @counter = 0
  end
  def finish
    STDERR.print "  #{@counter}\n"
  end
  def inc
    @counter += 1
    STDERR.print '.'
    STDERR.print "  #{@counter}\r" if (@counter % 10).zero?
  end
end
progress = Progressbar.new('recommendations')
log_file = File.open(filename).each_line do |log_line_file|

  next if log_line_file =~ /^#/
  progress.inc

  rec = Recommendation.example(log_line_file)
  carrier = rec.validating_carrier_iata
  total_recs += 1
  totals[carrier] ||= 0
  totals[carrier] += 1
  begin
    rec.find_commission!
    unless rec.commission.sellable?
      unsellable_recs += 1
      unsellables[carrier] ||= 0
      unsellables[carrier] += 1
    end
  rescue IataStash::NotFound
    next
  end

end
progress.finish
