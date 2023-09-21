class RdvSolidaritesWebhooksController < ApplicationController
  skip_before_action :authenticate_agent!
  skip_forgery_protection

  include FilterRdvSolidaritesWebhooksConcern

  def create
    webhook_job_for(model).perform_async(data_params.to_h, meta_params.to_h)
    head :ok
  end

  private

  def webhook_job_for(model)
    "RdvSolidaritesWebhooks::Process#{model}Job".constantize
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
