class InboundEmailsController < ApplicationController
  skip_before_action :authenticate_agent!, :verify_authenticity_token

  before_action :authenticate_brevo

  def brevo
    payload = request.params["items"].first
    TransferEmailReplyJob.perform_async(payload)
  end

  private

  def authenticate_brevo
    return if ActiveSupport::SecurityUtils.secure_compare(ENV["BREVO_INBOUND_PASSWORD"], params[:password])

    Sentry.capture_message("Brevo inbound controller was called without valid password")
    head :unauthorized
  end
end
