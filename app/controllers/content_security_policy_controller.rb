class ContentSecurityPolicyController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:report, :test_endpoint]
  skip_before_action :authenticate_agent!

  def test; end

  def test_endpoint
    render plain: "Form submission to same origin received"
  end

  def report
    request_body = request.body.read
    if request_body.present?
      report = JSON.parse(request_body)
      Rails.logger.info "CSP Violation: #{report.inspect}"
      Sentry.capture_message("CSP Violation: #{report.inspect}", level: :error)
    end
    head :ok
  rescue JSON::ParserError => e
    Rails.logger.error "Error parsing CSP report: #{e.message}"
    Sentry.capture_exception(e)
    head :bad_request
  end
end
