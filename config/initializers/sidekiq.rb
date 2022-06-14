Sidekiq.configure_server do |config|
  config.redis = { url: (ENV["REDIS_URL"] || 'redis://localhost:6379/0') }
  config.logger.level = ::Logger::INFO

  Rails.logger = Sidekiq.logger
  ActiveRecord::Base.logger = Sidekiq.logger

  config.on(:startup) do
    schedule_file = "config/schedule.yml"

    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file) if File.exist?(schedule_file)
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: (ENV["REDIS_URL"] || 'redis://localhost:6379/0') }
end
