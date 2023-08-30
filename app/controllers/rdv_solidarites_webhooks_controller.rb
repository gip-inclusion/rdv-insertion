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
      "User" => InboundWebhooks::RdvSolidarites::ProcessUserJob,
      "Rdv" => InboundWebhooks::RdvSolidarites::ProcessRdvJob,
      "UserProfile" => InboundWebhooks::RdvSolidarites::ProcessUserProfileJob,
      "Organisation" => InboundWebhooks::RdvSolidarites::ProcessOrganisationJob,
      "Motif" => InboundWebhooks::RdvSolidarites::ProcessMotifJob,
      "Lieu" => InboundWebhooks::RdvSolidarites::ProcessLieuJob,
      "Agent" => InboundWebhooks::RdvSolidarites::ProcessAgentJob,
      "AgentRole" => InboundWebhooks::RdvSolidarites::ProcessAgentRoleJob,
      "ReferentAssignation" => InboundWebhooks::RdvSolidarites::ProcessReferentAssignationJob
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
