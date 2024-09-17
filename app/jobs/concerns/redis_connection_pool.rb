module RedisConnectionPool
  extend ActiveSupport::Concern

  class_methods do
    def with_redis_connection_pool(&block)
      REDIS_CONNECTION_POOL.with(&block)
    end
  end

  def with_redis_connection_pool(&block)
    self.class.with_redis_connection_pool(&block)
  end
end
