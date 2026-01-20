# frozen_string_literal: true

# Protects against brute force, enumeration, and DoS attacks
# Uses Rails 8 built-in rate_limit method
module RateLimitingConcern
  extend ActiveSupport::Concern

  RATE_LIMIT_CACHE_STORE =
    if Rails.env.test?
      ActiveSupport::Cache::MemoryStore.new
    else
      ActiveSupport::Cache::RedisCacheStore.new(
        url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1"),
        namespace: "rate_limit"
      )
    end

  class_methods do
    # Custom rate_limit wrapper with consistent response format
    # @param limit [Integer] Maximum number of requests
    # @param period [ActiveSupport::Duration] Time window
    # @param options [Hash] Additional options (:only, :except, :by)
    def rate_limit_with_json_response(limit:, period:, **options)
      # Use high limits in test environment to avoid interfering with feature tests
      # Rate limiting specs test the mechanism directly via render_rate_limit_exceeded
      effective_limit = Rails.env.local? ? 500 : limit

      rate_limit(
        to: effective_limit,
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
      error: "Rate limit exceeded",
      retry_after: retry_after,
      message: "You have exceeded the allowed number of requests. Please retry in #{retry_after} seconds."
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
