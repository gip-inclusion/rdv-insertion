module Users
  class RdvsController < ApplicationController
    before_action :set_user, :ensure_rdv_solidarites_user_exists, :set_organisation, only: [:new]

    def new
      redirect_to rdv_solidarites_find_rdv_url, allow_other_host: true
    end

    private

    def rdv_solidarites_find_rdv_url
      "#{ENV['RDV_SOLIDARITES_URL']}/admin/organisations/#{@organisation.rdv_solidarites_organisation_id}" \
        "/agent_searches?user_ids[]=#{@user.rdv_solidarites_user_id}"
    end

    def set_user
      @user = policy_scope(User).preload(:organisations).find(params[:user_id])
    end

    def ensure_rdv_solidarites_user_exists
      recreate_rdv_solidarites_user(@user) if @user.rdv_solidarites_user_id.nil?
    end

    def set_organisation
      @organisation = current_organisation
    end
  end
end
