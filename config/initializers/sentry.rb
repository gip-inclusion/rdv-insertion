Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]
  config.environment = ENV["ENVIRONMENT_NAME"]
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  # Set tracesSampleRate to 1.0 to capture 100%
  # of transactions for performance monitoring.
  # We recommend adjusting this value in production
  config.traces_sample_rate = 0.05
  config.excluded_exceptions += ["WithAdvisoryLock::FailedToAcquireLock"]
end
