module RedisConnection
  CONNECTION_POOL = ConnectionPool.new(size: ENV.fetch("RAILS_MAX_THREADS", 5)) do
    Redis.new(url: Rails.configuration.x.redis_url)
  end

  def self.with_redis(&block)
    CONNECTION_POOL.with(&block)
  end
end