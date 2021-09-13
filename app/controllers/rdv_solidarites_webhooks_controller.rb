class RdvSolidaritesWebhooksController < ApplicationController
  skip_before_action :authenticate_agent!
  skip_forgery_protection

  include FilterRdvSolidaritesWebhooksConcern

  def create
    ProcessRdvSolidaritesWebhookJob.perform_async(data_params.to_h, meta_params.to_h)
    head :ok
  end

  private

  def data_params
    params.require(:data).permit!
  end

  def meta_params
    params.require(:meta).permit!
  end
end
