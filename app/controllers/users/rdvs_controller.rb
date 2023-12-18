module Users
  class RdvsController < ApplicationController
    before_action :set_user, :verify_user_is_sync_with_rdv_solidarites, only: [:new]

    def new
      redirect_to(rdv_solidarites_find_rdv_url)
    end

    private

    def rdv_solidarites_find_rdv_url
      "#{ENV['RDV_SOLIDARITES_URL']}/admin/organisations/#{@organisation.rdv_solidarites_organisation_id}" \
        "/agent_searches?user_ids[]=#{@user.rdv_solidarites_user_id}"
    end

    def set_user
      @user = policy_scope(User).includes(:organisations).find(params[:user_id])
    end

    def verify_user_is_sync_with_rdv_solidarites
      sync_user_with_rdv_solidarites(@user) if @user.rdv_solidarites_user_id.nil?
    end

    def set_organisation
      @organisation = policy_scope(Organisation).find_by(id: current_organisation_ids & user.organisation_ids)
    end
  end
end
