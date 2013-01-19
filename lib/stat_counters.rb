# encoding: utf-8
require 'mongo'

class StatCounters

  DATE_FORMAT = '%Y/%m/%d'
  DATE_HOUR_FORMAT = '%Y/%m/%d %H'

  def self.date_key(time=Time.now)
    key = time.is_a?(String) ? time : time.strftime(DATE_FORMAT)
    {:_id => key}
  end

  def self.date_index(time=Time.now)
    time.is_a?(String) ? time : time.strftime(DATE_FORMAT)
  end

  def self.hour_key(time=Time.now)
    key = time.is_a?(String) ? time : time.strftime(DATE_HOUR_FORMAT)
    {:_id => key}
  end

  def self.connection
    Mongoid.default_session
  end

  def self.json_set keys
    Hash[ keys.map { |k| [k, 1] } ]
  end

  def self.inc keys
    connection['counters_daily'].find(date_key).upsert('$inc' => json_set(keys))
    connection['counters_hourly'].find(hour_key).upsert('$inc' => json_set(keys))
  end

  def self.d_inc destination, keys
    connection['d_daily'].find(
      date: date_index,
      from: destination.from_iata,
      to: destination.to_iata,
      rt: destination.rt
    ).upsert('$inc' => json_set(keys))
  end

  def self.on_date(time=Time.now)
    connection['counters_daily'].find(date_key(time)).one
  end

  def self.on_daterange(date)
    connection['counters_daily'].find(date)
  end

  def self.on_hour(time=Time.now)
    connection['counters_hourly'].find(hour_key(time)).one
  end

  def self.search_on_date(time=Time.now, count=100)
    connection['d_daily'].find({'date' => date_index(time)}, :sort => [['search.api.total', -1]], :limit => count)
  end

  def self.search_on_daterange(date, count=100)
    connection['d_daily'].find(date, :sort => [['search.api.total', -1]], :limit => count)
  end

  # FIXME UGLY пытаемся выводить данные в человекочитабельном виде
  def self.debug_yml(bson)
    bson.to_yaml.gsub(' !ruby/hash:BSON::OrderedHash', '').gsub(' !map:BSON::OrderedHash', '')
  end

  def self.build_datetime_conditions(key, value)
    firstdate, lastdate = value.strip.split('-')
    lastdate ||= firstdate
    interval = firstdate.to_date..lastdate.to_date
    { key => {'$gte' => interval.first.strftime(DATE_FORMAT), '$lte' => interval.last.strftime(DATE_FORMAT)}}
  end

  def self.deep_merge_sum(hash1, hash2)
    hash1 ||= {}
    hash2 ||= {}
    sum = hash1
    hash2.each_pair do |k,v|
      tv = hash1[k]
      if tv.is_a?(Hash) && v.is_a?(Hash)
        sum[k] = deep_merge_sum(tv, v)
      elsif v.is_a?(Hash)
        sum[k] = v
      else
        sum[k] = tv.to_i + v.to_i
      end
    end
    sum
  end

end
