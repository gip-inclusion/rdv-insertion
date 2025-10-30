RDV_SOLIDARITES_DEPENDENT_TRANSACTIONS = [
  # Invitations - Vérification de créneaux
  "InvitationsController#create",
  "Api::V1::UsersController#invite",
  "Api::V1::UsersController#create_and_invite"
].freeze

Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]
  config.environment = ENV["ENVIRONMENT_NAME"]
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  # Set tracesSampleRate to 1.0 to capture 100%
  # of transactions for performance monitoring.
  # We recommend adjusting this value in production

  # crash-free sessions tracking
  config.auto_session_tracking = true
  config.release = ENV["SOURCE_VERSION"] || "development"

  # filter transactions for Apdex relevance
  config.traces_sampler = lambda do |sampling_context|
    transaction_context = sampling_context[:transaction_context]
    transaction_name = transaction_context[:name]
    op = transaction_context[:op]

    # Exclude all Sidekiq background jobs (asynchronous processing) (0%)
    return 0.0 if op == "queue.sidekiq"

    # Exclude specific RDV Solidarités dependent transactions (0%)
    return 0.0 if RDV_SOLIDARITES_DEPENDENT_TRANSACTIONS.include?(transaction_name)

    # Default sampling rate (5%)
    0.05
  end

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
