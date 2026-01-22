class RdvSolidaritesWebhooksController < ApplicationController
  skip_before_action :authenticate_agent!
  skip_forgery_protection

  rate_limit_with_json_response limit: RATE_LIMITS[:rdv_solidarites_webhooks]

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
