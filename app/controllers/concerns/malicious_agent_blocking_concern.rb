# frozen_string_literal: true

# Blocks requests from known malicious user agents (security scanners, bots)
module MaliciousAgentBlockingConcern
  extend ActiveSupport::Concern

  BLOCKED_USER_AGENTS = %w[sqlmap nikto dirbuster gobuster masscan zmap].freeze

  included do
    before_action :block_malicious_user_agents
  end

  private

  def block_malicious_user_agents
    return unless malicious_user_agent?

    log_blocked_request
    report_blocked_request_to_sentry

    render json: { error: "Forbidden" }, status: :forbidden
  end

  def malicious_user_agent?
    user_agent = request.user_agent.to_s.downcase
    BLOCKED_USER_AGENTS.any? { |agent| user_agent.include?(agent) }
  end

  def log_blocked_request
    Rails.logger.error(
      "[Security] Blocked malicious request: " \
      "ip=#{request.ip} " \
      "path=#{request.path} " \
      "user_agent=#{request.user_agent}"
    )
  end

  def report_blocked_request_to_sentry
    return unless defined?(Sentry)

    Sentry.capture_message(
      "Blocked malicious request",
      level: :error,
      extra: {
        ip: request.ip,
        path: request.path,
        user_agent: request.user_agent
      }
    )
  end
end
