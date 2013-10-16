# encoding: utf-8

module RedisConnection

  def redis
    @redis ||= Redis.new(host: Conf.redis.host, port: Conf.redis.port)
  #rescue StandardError => e
    #do smth
  end

end

