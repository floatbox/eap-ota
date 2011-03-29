# Learn more: http://github.com/javan/whenever
set :output, "log/cron.log"

every :day do
  rake 'completer:regen'
end

every 5.minutes do
  runner 'Order.cancel_stale!'
end

every 10.minutes do
  runner 'Amadeus::Session.housekeep'
end

every :day do
  command '/usr/sbin/logrotate -s /home/rack/logrotate/status /home/rack/logrotate/logrotate.conf'
end

every :day do
  command 'cd /home/rack/eviterra/shared/backup && (mysqldump -uroot eviterra | gzip > eviterra-`date +\%F`.sql.gz ) && ln -sf eviterra-`date +\%F`.sql.gz latest.sql.gz'
end

every 1.day, :at => '18:00' do
  command 'script/cbrusd && touch tmp/restart.txt'
end
