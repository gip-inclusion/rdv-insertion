# Protects against brute force, enumeration, and DoS attacks
module RateLimitingConcern
  extend ActiveSupport::Concern

  RATE_LIMIT_CACHE_STORE =
    ActiveSupport::Cache::RedisCacheStore.new(
      url: Rails.configuration.x.redis_url,
      namespace: "rate_limit"
    )

  RATE_LIMITS = {
    default: ENV.fetch("RATE_LIMIT_DEFAULT", 500).to_i,
    rdv_solidarites_webhooks: ENV.fetch("RATE_LIMIT_RDV_SOLIDARITES_WEBHOOKS", 1000).to_i,
    api_bulk: ENV.fetch("RATE_LIMIT_API_BULK", 5).to_i,
    inbound_emails: ENV.fetch("RATE_LIMIT_INBOUND_EMAILS", 1000).to_i,
    brevo_webhooks: ENV.fetch("RATE_LIMIT_BREVO_WEBHOOKS", 1000).to_i,
    sessions: ENV.fetch("RATE_LIMIT_SESSIONS", 10).to_i,
    invitations: ENV.fetch("RATE_LIMIT_INVITATIONS", 30).to_i,
    stats: ENV.fetch("RATE_LIMIT_STATS", 60).to_i,
    static_pages: ENV.fetch("RATE_LIMIT_STATIC_PAGES", 60).to_i,
    super_admin_auth: ENV.fetch("RATE_LIMIT_SUPER_ADMIN_AUTH", 10).to_i
  }.freeze

  included do
    rate_limit(
      to: Rails.env.local? ? 10_000 : RATE_LIMITS[:default],
      within: 5.minutes,
      by: -> { "#{action_name}:#{request.remote_ip}" },
      name: "default",
      store: RATE_LIMIT_CACHE_STORE,
      with: -> { render_rate_limit_exceeded(RATE_LIMITS[:default], 5.minutes) },
      unless: :rate_limit_overridden?
    )
  end

  class_methods do
    def override_rate_limit(limit:, period: 1.minute, **options)
      raise ArgumentError, "a limit must be provided" if limit.nil?

      only_actions = Array(options[:only]).map(&:to_sym)
      overridden_rate_limit_actions.merge(only_actions.presence || [:_all])

      rate_limit(
        to: Rails.env.local? ? 1 : limit,
        within: period,
        by: options.delete(:by) || -> { "#{action_name}:#{request.remote_ip}" },
        name: "override",
        store: RATE_LIMIT_CACHE_STORE,
        with: -> { render_rate_limit_exceeded(limit, period) },
        **options
      )
    end

    def overridden_rate_limit_actions
      @overridden_rate_limit_actions ||= Set.new
    end
  end

  private

  def rate_limit_overridden?
    overridden_actions = self.class.overridden_rate_limit_actions
    overridden_actions.include?(:_all) || overridden_actions.include?(action_name.to_sym)
  end

  def render_rate_limit_exceeded(limit, period)
    log_rate_limit_exceeded(limit)
    report_rate_limit_to_sentry

    # we cannot compute precisely the retry_after value without getting
    # the keys from redis relying on rate limiting internals,
    # so we use the period as a fallback
    retry_after = period.to_i
    response.headers["Retry-After"] = retry_after.to_s
    response.headers["X-RateLimit-Limit"] = limit.to_s
    response.headers["X-RateLimit-Remaining"] = "0"

    render json: {
      error: "Limite de requêtes atteinte",
      retry_after: retry_after,
      message: "Vous avez dépassé la limite de #{limit} requêtes autorisées. " \
               "Veuillez réessayer dans moins de #{retry_after} secondes."
    }, status: :too_many_requests
  end

  def report_rate_limit_to_sentry
    Sentry.capture_message(
      "Rate limit exceeded",
      extra: {
        ip: request.ip,
        path: request.path,
        controller: controller_name,
        action: action_name,
        user_agent: request.user_agent
      }
    )
  end

  def log_rate_limit_exceeded(limit)
    Rails.logger.warn(
      "[RateLimit] Throttled request: " \
      "ip=#{request.ip} " \
      "path=#{request.path} " \
      "limit=#{limit} " \
      "controller=#{controller_name}##{action_name}"
    )
  end
end
