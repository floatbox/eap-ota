require 'mongo'

class StatCounters

  def database
    'eviterra_development'
  end

  def date_key
    key = {:date => Time.now.strftime('%Y/%m/%d')}
  end

  def connection
    @connection = Mongo::Connection.new()
    @db = @connection[database]
    @counters = @db['counters']
  end

  def push data
    @counters.update(date_key, '$inc' => data)
  end

end