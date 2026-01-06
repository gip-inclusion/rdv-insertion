# frozen_string_literal: true

# Rate limiting configuration for RISK-GENERAL-006
# Protects against brute force, enumeration, and DoS attacks
# See: docs/security/SEC-GENERAL.md#risk-general-006

class Rack::Attack
  # Configure Redis-backed cache for distributed rate limiting
  Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(
    url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1"),
    namespace: "rack_attack"
  )

  # Allow localhost in development/test
  safelist("allow-localhost") do |req|
    Rails.env.local? && ["127.0.0.1", "::1"].include?(req.ip)
  end

  WEBHOOK_PATHS = %w[
    /rdv_solidarites_webhooks /brevo/mail_webhooks /brevo/sms_webhooks /inbound_emails/brevo
  ].freeze

  STATIC_PATHS = %w[/ /mentions-legales /cgu /politique-de-confidentialite /accessibilite].freeze

  # 1. General rate limiting - 300 req/5min (safety net)
  throttle("req/ip", limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?("/assets", "/packs")
  end

  # 2. Authentication endpoints - strict limits for brute force protection
  throttle("logins/ip", limit: 5, period: 1.minute) do |req|
    req.ip if req.path == "/sign_in" && req.get?
  end

  throttle("auth_callback/ip", limit: 10, period: 1.minute) do |req|
    req.ip if req.path.start_with?("/auth/") && req.path.include?("/callback")
  end

  throttle("sessions/ip", limit: 5, period: 1.minute) do |req|
    req.ip if req.path == "/sessions" && req.post?
  end

  # 3. Super Admin - very strict (3/min)
  throttle("super_admin_auth/ip", limit: 3, period: 1.minute) do |req|
    req.ip if req.path.start_with?("/super_admin_authentication_request")
  end

  # 4. API endpoints
  throttle("api/ip", limit: 100, period: 1.minute) do |req|
    req.ip if req.path.start_with?("/api/")
  end

  throttle("api/users/ip", limit: 20, period: 1.minute) do |req|
    req.ip if req.path.start_with?("/api/v1/organisations/") && req.path.include?("/users") && req.post?
  end

  throttle("api/users/bulk/ip", limit: 5, period: 1.minute) do |req|
    req.ip if req.path.include?("create_and_invite_many") && req.post?
  end

  # 5. Webhooks - high volume (1000/min)
  throttle("webhooks/ip", limit: 1000, period: 1.minute) do |req|
    req.ip if req.post? && WEBHOOK_PATHS.any? { |path| req.path.start_with?(path) }
  end

  # 6. Public invitation endpoints
  throttle("invitations/ip", limit: 30, period: 1.minute) do |req|
    req.ip if req.path == "/invitation" || req.path.start_with?("/r/")
  end

  throttle("invitations/redirect/ip", limit: 20, period: 1.minute) do |req|
    req.ip if req.path == "/invitations/redirect"
  end

  # 7. Search endpoints - enumeration prevention
  throttle("organisations/search/ip", limit: 30, period: 1.minute) do |req|
    req.ip if %w[/organisations/search /organisations/geolocated].include?(req.path)
  end

  throttle("users/search/ip", limit: 30, period: 1.minute) do |req|
    req.ip if req.path == "/users/searches" && req.post?
  end

  # 8. Stats and static pages
  throttle("stats/ip", limit: 60, period: 1.minute) do |req|
    req.ip if req.path.start_with?("/stats") || req.path.end_with?("/stats")
  end

  throttle("static/ip", limit: 60, period: 1.minute) do |req|
    req.ip if STATIC_PATHS.include?(req.path)
  end

  # Block malicious user agents
  blocklist("block/bad-agents") do |req|
    bad_agents = %w[sqlmap nikto dirbuster gobuster masscan zmap]
    user_agent = req.user_agent.to_s.downcase
    bad_agents.any? { |agent| user_agent.include?(agent) }
  end
end
