require_relative "../middlewares/sidekiq/capture_current_agent"
require_relative "../middlewares/sidekiq/set_current_agent"

Sidekiq.configure_server do |config|
  config.redis = { url: Rails.configuration.x.redis_url }
  config.logger.level = Rails.env.development? ? Logger::DEBUG : Logger::INFO
  # when jobs are pushing other jobs to Sidekiq they are acting as clients, so we need to add the middleware here
  config.client_middleware do |chain|
    chain.prepend Sidekiq::Middleware::CaptureCurrentAgent
  end
  config.server_middleware do |chain|
    chain.prepend Sidekiq::Middleware::SetCurrentAgent
  end

  Rails.logger = Sidekiq.logger
  ActiveRecord::Base.logger = Sidekiq.logger
end

Sidekiq.logger.level = Logger::WARN if Rails.env.test?

Sidekiq.strict_args!(false)

Sidekiq.configure_client do |config|
  config.redis = { url: Rails.configuration.x.redis_url }
  config.client_middleware do |chain|
    chain.prepend Sidekiq::Middleware::CaptureCurrentAgent
  end
end
