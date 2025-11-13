Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]
  config.environment = ENV["ENVIRONMENT_NAME"]
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  # Set tracesSampleRate to 1.0 to capture 100%
  # of transactions for performance monitoring.
  # We recommend adjusting this value in production
  config.traces_sample_rate = 0.05
  # crash-free sessions tracking
  config.auto_session_tracking = true
  # "SOURCE_VERSION" env variable is set automatically by Scalingo as the SHA of the commit
  config.release = ENV["SOURCE_VERSION"] unless Rails.env.local?

  config.before_send = lambda do |event, _hint|
    # We filter sensitive data from Sidekiq arguments
    sidekiq_args = event.contexts.dig(:sidekiq, "args")
    if sidekiq_args
      sidekiq_args.each do |arg|
        Sidekiq::ArgumentsFilter.filter_arguments!(arg["arguments"]) if arg.is_a?(Hash) && arg["arguments"]
      end
    end
    event
  end

  config.excluded_exceptions += ["WithAdvisoryLock::FailedToAcquireLock"]
end
