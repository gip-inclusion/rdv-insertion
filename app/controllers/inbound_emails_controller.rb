class InboundEmailsController < ApplicationController
  skip_before_action :authenticate_agent!, :verify_authenticity_token

  # High volume webhook rate limit: 1000 requests per minute
  rate_limit_with_json_response limit: 1000, period: 1.minute

  before_action :authenticate_brevo, :store_last_inbound_email_received_at

  def brevo
    payload = request.params["items"].first
    TransferEmailReplyJob.perform_later(payload)
  end

  private

  def authenticate_brevo
    return if ActiveSupport::SecurityUtils.secure_compare(ENV["BREVO_INBOUND_PASSWORD"], params[:password])

    Sentry.capture_message("Brevo inbound controller was called without valid password")
    head :unauthorized
  end

  def store_last_inbound_email_received_at
    RedisConnection.with_redis do |redis|
      redis.set("last_inbound_email_received_at", Time.current.to_i, ex: 7.days.to_i)
    end
  end
end
