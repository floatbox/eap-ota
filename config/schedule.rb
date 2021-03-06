# Learn more: http://github.com/javan/whenever
set :output, "log/cron.log"

job_type :command_at_current, "cd :path && :task :output"

#every :day do
#  rake 'completer:regen'
#end

every 5.minutes do
  runner 'Order.cancel_stale!'
end

every 5.minutes do
  runner 'Order.set_error_ticket_status!'
end

every 10.minutes do
#  runner 'Notification.process_queued_emails!'
end

every 10.minutes do
  runner 'Amadeus::Session.housekeep'
  #runner 'Amadeus::Session.dirty_housekeep'
end

every 1.hour do
  runner 'Subscription.defrost_frozen!'
  #runner 'Amadeus::Session.dirty_housekeep'
end

every :day, :at => '2:00 am' do
  runner 'script/sync_canceled_pnrs'
end

every :day, :at => '5:00 am' do
  runner 'Tripster.load_cities'
end

every :day, :at => '6:00 pm' do
  runner 'CBR.preload_rate'
end

### FILL CUSTOMERS Table From ORDERS
#every 5.minutes do
#  runner 'DataMigration.fill_customers_for_orders'
#end

#every 1.day, :at => '18:00' do
#  command_at_current 'script/cbrusd && touch tmp/restart.txt'
#end

