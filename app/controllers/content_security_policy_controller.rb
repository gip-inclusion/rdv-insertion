class ContentSecurityPolicyController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:report]
  skip_before_action :authenticate_agent!

  ORIGIN_URI_PREFIXES_TO_IGNORE = [
    # We get a lot of violations from the invitations redirect page because there are translate
    # scripts from google that are loaded from the page. These violations are not important since this is a redirection
    "#{ENV['HOST']}/invitation", "#{ENV['HOST']}/r/"
  ].freeze

  def report
    request_body = request.body.read
    if request_body.present?
      report = JSON.parse(request_body)
      Rails.logger.info "CSP Violation: #{report.inspect}" if Rails.env.development?
      Sentry.capture_message("CSP Violation: #{report.inspect}", level: :error) if should_report_csp_violation?(report)
    end
    head :ok
  rescue JSON::ParserError => e
    Rails.logger.error "Error parsing CSP report: #{e.message}"
    Sentry.capture_exception(e)
    head :bad_request
  end

  private

  def should_report_csp_violation?(report)
    !report.dig("csp-report", "document-uri").start_with?(*ORIGIN_URI_PREFIXES_TO_IGNORE)
  end
end
