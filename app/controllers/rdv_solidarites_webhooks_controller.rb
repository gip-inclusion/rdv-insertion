class RdvSolidaritesWebhooksController < ApplicationController
  skip_before_action :authenticate_agent!
  skip_forgery_protection

  # Webhook rate limit: uses default, can be increased via RATE_LIMIT_RDV_SOLIDARITES_WEBHOOKS during high traffic
  rate_limit_with_json_response limit: ENV.fetch("RATE_LIMIT_RDV_SOLIDARITES_WEBHOOKS", ENV["RATE_LIMIT_DEFAULT"]).to_i,
                                period: 1.minute

  include FilterRdvSolidaritesWebhooksConcern

  def create
    webhook_job_for(model).perform_later(data_params.to_h, meta_params.to_h)
    head :ok
  end

  private

  def webhook_job_for(model)
    "InboundWebhooks::RdvSolidarites::Process#{model}Job".constantize
  end

  def model
    params[:meta][:model]
  end

  def data_params
    params.require(:data).permit!
  end

  def meta_params
    params.require(:meta).permit!
  end
end
