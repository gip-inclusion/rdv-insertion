module RdvSolidaritesWebhooks
  class ProcessUserProfileJob < ApplicationJob
    def perform(data, meta)
      @data = data.deep_symbolize_keys
      @meta = meta.deep_symbolize_keys
      return if @data[:user].blank? || user.blank? || organisation.blank?

      # if webhook_reason is rgpd we don't want to delete the user, only nullify the relation with rdvs
      # in this case, the ProcessUserJob will also receive a webhook, we let him do that
      return if webhook_reason == "rgpd"

      if event == "destroyed"
        remove_user_from_organisation
      else
        attach_user_to_org
      end
    end

    private

    def event
      @meta[:event]
    end

    def webhook_reason
      @meta[:webhook_reason]
    end

    def rdv_solidarites_user_id
      @data[:user][:id]
    end

    def rdv_solidarites_organisation_id
      @data[:organisation][:id]
    end

    def user
      @user ||= User.find_by(rdv_solidarites_user_id: rdv_solidarites_user_id)
    end

    def organisation
      @organisation ||= Organisation.find_by(rdv_solidarites_organisation_id: rdv_solidarites_organisation_id)
    end

    def attach_user_to_org
      user.organisations << organisation unless user.reload.organisation_ids.include?(organisation.id)
    end

    def remove_user_from_organisation
      user.delete_organisation(organisation) if user.reload.organisation_ids.include?(organisation.id)
      SoftDeleteUserJob.perform_async(rdv_solidarites_user_id) if user.reload.organisations.empty?
    end
  end
end
