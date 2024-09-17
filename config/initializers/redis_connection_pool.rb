require "connection_pool"
REDIS_CONNECTION_POOL = ConnectionPool.new(size: 10) { Redis.new(url: ENV["REDIS_URL"] || "redis://localhost:6379/0") }
