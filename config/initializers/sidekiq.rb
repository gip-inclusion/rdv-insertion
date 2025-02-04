require "sidekiq"

Rails.root.glob("app/lib/sidekiq/**/*.rb").each do |file|
  require file
end

Sidekiq.configure_server do |config|
  config.logger = Sidekiq::Logger.new($stdout)
  config.logger.level = Rails.env.development? ? Logger::DEBUG : Logger::INFO
  config.logger.formatter = Sidekiq::Logger::Formatters::CustomLogFormatter.new

  config.redis = { url: Rails.configuration.x.redis_url }

  # when jobs are pushing other jobs to Sidekiq they are acting as clients, so we need to add the middleware here
  config.client_middleware do |chain|
    chain.prepend Sidekiq::Middleware::CaptureCurrentAgent
  end
  config.server_middleware do |chain|
    chain.prepend Sidekiq::Middleware::SetCurrentAgent
  end
end

Sidekiq.logger.level = Logger::WARN if Rails.env.test?

Sidekiq.strict_args!(false)

Sidekiq.configure_client do |config|
  config.redis = { url: Rails.configuration.x.redis_url }
  config.client_middleware do |chain|
    chain.prepend Sidekiq::Middleware::CaptureCurrentAgent
  end
end
