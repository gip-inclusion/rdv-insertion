require_relative "../middlewares/sidekiq/capture_current_agent"
require_relative "../middlewares/sidekiq/set_current_agent"

Sidekiq.configure_server do |config|
  config.redis = { url: ENV["REDIS_URL"] || "redis://localhost:6379/0" }
  config.logger.level = Logger::INFO
  # when jobs are pushing other jobs to Sidekiq they are acting as clients, so we need to add the middleware here
  config.client_middleware do |chain|
    chain.add Sidekiq::Middleware::CaptureCurrentAgent
  end
  config.server_middleware do |chain|
    chain.add Sidekiq::Middleware::SetCurrentAgent
  end

  Rails.logger = Sidekiq.logger
  ActiveRecord::Base.logger = Sidekiq.logger

  config.on(:startup) do
    schedule = YAML.load_file("config/schedule.yml")

    schedule.each do |task, args|
      schedule.delete(task) if args["run_only_in_env"]&.exclude?(ENV["SENTRY_ENVIRONMENT"])
    end

    Sidekiq::Cron::Job.load_from_hash(schedule)
  end
end

Sidekiq.logger.level = Logger::WARN if Rails.env.test?

Sidekiq.strict_args!(false)

Sidekiq.configure_client do |config|
  config.redis = { url: ENV["REDIS_URL"] || "redis://localhost:6379/0" }
  config.client_middleware do |chain|
    chain.add Sidekiq::Middleware::CaptureCurrentAgent
  end
end
