module InboundWebhooks
  module RdvSolidarites
    class ProcessUserProfileJob < ApplicationJob
      def perform(data, meta)
        @data = data.deep_symbolize_keys
        @meta = meta.deep_symbolize_keys
        return if @data[:user].blank? || user.blank? || organisation.blank?

        # if webhook_reason is rgpd, it means the user has been deleted in RDV-S
        if webhook_reason == "rgpd"
          nullify_user_rdv_solidarites_id
        elsif event == "destroyed"
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

      def nullify_user_rdv_solidarites_id
        return unless user # if the user is in multiple organisations, he will already have been nullified

        NullifyRdvSolidaritesIdJob.perform_async("User", user&.id)
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
end
