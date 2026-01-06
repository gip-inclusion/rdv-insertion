# frozen_string_literal: true

# Rack::Attack responses and instrumentation
# Separated from main configuration to keep class size manageable

# Custom response for throttled requests (429 Too Many Requests)
Rack::Attack.throttled_responder = lambda do |req|
  match_data = req.env["rack.attack.match_data"]
  now = Time.zone.now

  headers = {
    "Content-Type" => "application/json",
    "Retry-After" => (match_data[:period] - (now.to_i % match_data[:period])).to_s,
    "X-RateLimit-Limit" => match_data[:limit].to_s,
    "X-RateLimit-Remaining" => "0",
    "X-RateLimit-Reset" => (now + (match_data[:period] - (now.to_i % match_data[:period]))).iso8601
  }

  body = {
    error: "Rate limit exceeded",
    retry_after: headers["Retry-After"].to_i,
    message: "You have exceeded the allowed number of requests. Please retry in #{headers['Retry-After']} seconds."
  }.to_json

  [429, headers, [body]]
end

# Custom response for blocked requests (403 Forbidden)
Rack::Attack.blocklisted_responder = lambda do |_req|
  [403, { "Content-Type" => "application/json" }, [{ error: "Forbidden" }.to_json]]
end

# Log throttled requests for monitoring
ActiveSupport::Notifications.subscribe("throttle.rack_attack") do |_name, _start, _finish, _id, payload|
  req = payload[:request]
  Rails.logger.warn(
    "[Rack::Attack] Throttled request: " \
    "ip=#{req.ip} " \
    "path=#{req.path} " \
    "matched=#{req.env['rack.attack.matched']} " \
    "discriminator=#{req.env['rack.attack.match_discriminator']}"
  )

  # Report to Sentry for monitoring
  if defined?(Sentry)
    Sentry.capture_message(
      "Rate limit exceeded",
      level: :warning,
      extra: {
        ip: req.ip,
        path: req.path,
        matched: req.env["rack.attack.matched"],
        user_agent: req.user_agent
      }
    )
  end
end

# Log blocked requests
ActiveSupport::Notifications.subscribe("blocklist.rack_attack") do |_name, _start, _finish, _id, payload|
  req = payload[:request]
  Rails.logger.error(
    "[Rack::Attack] Blocked request: " \
    "ip=#{req.ip} " \
    "path=#{req.path} " \
    "matched=#{req.env['rack.attack.matched']}"
  )

  if defined?(Sentry)
    Sentry.capture_message(
      "Blocked malicious request",
      level: :error,
      extra: {
        ip: req.ip,
        path: req.path,
        matched: req.env["rack.attack.matched"],
        user_agent: req.user_agent
      }
    )
  end
end
