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
    sessions: ENV.fetch("RATE_LIMIT_SESSIONS", 5).to_i,
    invitations: ENV.fetch("RATE_LIMIT_INVITATIONS", 30).to_i,
    stats: ENV.fetch("RATE_LIMIT_STATS", 60).to_i,
    static_pages: ENV.fetch("RATE_LIMIT_STATIC_PAGES", 60).to_i,
    super_admin_auth: ENV.fetch("RATE_LIMIT_SUPER_ADMIN_AUTH", 3).to_i
  }.freeze

  class_methods do
    def rate_limit_with_json_response(limit:, period: 1.minute, **options)
      raise ArgumentError, "a limit must be provided" if limit.nil?

      rate_limit(
        to: Rails.env.local? ? 10_000 : limit,
        within: period,
        store: RATE_LIMIT_CACHE_STORE,
        with: -> { render_rate_limit_exceeded(limit, period) },
        **options
      )
    end
  end

  private

  def render_rate_limit_exceeded(limit, period)
    retry_after = compute_retry_after(period)

    log_rate_limit_exceeded(limit)
    set_rate_limit_headers(limit, retry_after)

    render json: rate_limit_error_body(retry_after), status: :too_many_requests
  end

  def compute_retry_after(period)
    now = Time.zone.now
    period.to_i - (now.to_i % period.to_i)
  end

  def set_rate_limit_headers(limit, retry_after)
    response.headers["Retry-After"] = retry_after.to_s
    response.headers["X-RateLimit-Limit"] = limit.to_s
    response.headers["X-RateLimit-Remaining"] = "0"
    response.headers["X-RateLimit-Reset"] = (Time.zone.now + retry_after).iso8601
  end

  def rate_limit_error_body(retry_after)
    {
      error: "Limite de requêtes atteinte",
      retry_after: retry_after,
      message: "Vous avez atteint le nombre de requêtes autorisées. Veuillez réessayer dans #{retry_after} secondes."
    }
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
