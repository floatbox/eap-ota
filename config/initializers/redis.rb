# encoding: utf-8

RedisClient = Redis.new(host: Conf.redis.host, port: Conf.redis.port)
