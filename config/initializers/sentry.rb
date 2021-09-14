Sentry.init do |config|
  config.dsn = 'https://1741eef5f07447c5aa48ff791cd969d6@o548798.ingest.sentry.io/5958991'
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  # Set tracesSampleRate to 1.0 to capture 100%
  # of transactions for performance monitoring.
  # We recommend adjusting this value in production
  # config.traces_sample_rate = 0.5
  # or
  config.traces_sampler = lambda do |_context|
    true
  end
end
