# frozen_string_literal: true

# Protects against brute force, enumeration, and DoS attacks
# Uses Rails 8 built-in rate_limit method
module RateLimitingConcern
  extend ActiveSupport::Concern

  RATE_LIMIT_CACHE_STORE = ActiveSupport::Cache::RedisCacheStore.new(
    url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1"),
    namespace: "rate_limit"
  )

  class_methods do
    # Custom rate_limit wrapper with consistent response format
    # @param limit [Integer] Maximum number of requests
    # @param period [ActiveSupport::Duration] Time window
    # @param options [Hash] Additional options (:only, :except, :by)
    def rate_limit_with_json_response(limit:, period:, **options)
      rate_limit(
        to: limit,
        within: period,
        store: RATE_LIMIT_CACHE_STORE,
        with: -> { render_rate_limit_exceeded(limit, period) },
        **options
      )
    end
  end

  private

  def render_rate_limit_exceeded(limit, period)
    now = Time.zone.now
    retry_after = period.to_i - (now.to_i % period.to_i)
    reset_time = now + retry_after

    log_rate_limit_exceeded(limit)
    report_rate_limit_to_sentry

    response.headers["Retry-After"] = retry_after.to_s
    response.headers["X-RateLimit-Limit"] = limit.to_s
    response.headers["X-RateLimit-Remaining"] = "0"
    response.headers["X-RateLimit-Reset"] = reset_time.iso8601

    render json: {
      error: "Rate limit exceeded",
      retry_after: retry_after,
      message: "You have exceeded the allowed number of requests. Please retry in #{retry_after} seconds."
    }, status: :too_many_requests
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

  def report_rate_limit_to_sentry
    return unless defined?(Sentry)

    Sentry.capture_message(
      "Rate limit exceeded",
      level: :warning,
      extra: {
        ip: request.ip,
        path: request.path,
        controller: controller_name,
        action: action_name,
        user_agent: request.user_agent
      }
    )
  end
end
