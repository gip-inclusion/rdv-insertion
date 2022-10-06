class RdvSolidaritesWebhooksController < ApplicationController
  skip_before_action :authenticate_agent!
  skip_forgery_protection

  include FilterRdvSolidaritesWebhooksConcern

  def create
    webhook_jobs[model].perform_async(data_params.to_h, meta_params.to_h)
    head :ok
  end

  private

  def webhook_jobs
    {
      "User" => RdvSolidaritesWebhooks::ProcessUserJob,
      "Rdv" => RdvSolidaritesWebhooks::ProcessRdvJob,
      "UserProfile" => RdvSolidaritesWebhooks::ProcessUserProfileJob,
      "Organisation" => RdvSolidaritesWebhooks::ProcessOrganisationJob,
      "Motif" => RdvSolidaritesWebhooks::ProcessMotifJob,
      "Lieu" => RdvSolidaritesWebhooks::ProcessLieuJob
    }
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
