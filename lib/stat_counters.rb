require 'mongo'

class StatCounters

  def self.date_key
    key = {:_id => Time.now.strftime('%Y/%m/%d')}
  end

  def self.hour_key
    key = {:_id => Time.now.strftime('%Y/%m/%d %H')}
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

end