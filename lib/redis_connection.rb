# encoding: utf-8

module RedisConnection

  def redis
    @redis ||= Redis.new(host: Conf.redis.host, port: Conf.redis.port)
  end

end

