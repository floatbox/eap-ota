# Learn more: http://github.com/javan/whenever
set :output, "log/cron.log"

job_type :command_at_current, "cd :path && :task :output"

every :day do
  rake 'completer:regen'
end

every 10.minutes do
  # слишком болшие запросы рамблер не принимает, чаще, чем раз в минуту отправить не получится
  runner '100.times {RamblerCache.send_to_rambler}'
end

every 5.minutes do
  runner 'Order.cancel_stale!'
end

every 5.minutes do
  runner 'Notification.process_queued_emails!'
end

every 10.minutes do
  runner 'Amadeus::Session.housekeep'
  #runner 'Amadeus::Session.dirty_housekeep'
end

every 1.hour do
  runner 'Subscription.defrost_frozen!'
  #runner 'Amadeus::Session.dirty_housekeep'
end

every :wednesday, :at => '12:30 am' do
  runner 'script/amadeus_rate'
end

#every 1.day, :at => '18:00' do
#  command_at_current 'script/cbrusd && touch tmp/restart.txt'
#end

