Sidekiq.configure_server do |config|
  config.redis = { url: (ENV["REDIS_URL"] || 'redis://localhost:6379/0') }
  config.logger.level = ::Logger::INFO

  Rails.logger = Sidekiq.logger
  ActiveRecord::Base.logger = Sidekiq.logger
end

Sidekiq.configure_client do |config|
  config.redis = { url: (ENV["REDIS_URL"] || 'redis://localhost:6379/0') }
end
