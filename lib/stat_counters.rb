require 'mongo'

class StatCounters

  DATE_FORMAT = '%Y/%m/%d'
  DATE_HOUR_FORMAT = '%Y/%m/%d %H'

  def self.date_key(time=Time.now)
    key = time.is_a?(String) ? time : time.strftime(DATE_FORMAT)
    {:_id => key}
  end

  def self.hour_key(time=Time.now)
    key = time.is_a?(String) ? time : time.strftime(DATE_HOUR_FORMAT)
    {:_id => key}
  end

  def self.connection
    Mongoid.master
  end

  def self.value keys
    {}.tap do |h| 
      keys.each do |k|
        h[k] = 1
      end
    end
  end

  def self.inc keys
    connection['counters_daily'].update(date_key, {'$inc' => value(keys)}, :upsert => true)
    connection['counters_hourly'].update(hour_key, {'$inc' => value(keys)}, :upsert => true)
  end

  def self.on_date(time=Time.now)
    connection['counters_daily'].find_one(date_key(time))
  end

  def self.on_hour(time=Time.now)
    connection['counters_hourly'].find_one(hour_key(time))
  end

  # FIXME UGLY пытаемся выводить данные в человекочитабельном виде
  def self.debug_yml(bson)
    bson.to_yaml.gsub(' !ruby/hash:BSON::OrderedHash', '').gsub(' !map:BSON::OrderedHash', '')
  end

end
