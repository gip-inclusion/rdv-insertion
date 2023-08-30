module InboundWebhooks
  module RdvSolidarites
    class ProcessUserProfileJob < ApplicationJob
      def perform(data, meta)
        @data = data.deep_symbolize_keys
        @meta = meta.deep_symbolize_keys

        return if @data[:user].blank?
        return if applicant.blank? || organisation.blank?

        if event == "destroyed"
          remove_applicant_from_organisation
        else
          attach_applicant_to_org
        end
      end

      private

      def event
        @meta[:event]
      end

      def rdv_solidarites_user_id
        @data[:user][:id]
      end

      def rdv_solidarites_organisation_id
        @data[:organisation][:id]
      end

      def applicant
        @applicant ||= Applicant.find_by(rdv_solidarites_user_id: rdv_solidarites_user_id)
      end

      def organisation
        @organisation ||= Organisation.find_by(rdv_solidarites_organisation_id: rdv_solidarites_organisation_id)
      end

      def attach_applicant_to_org
        applicant.organisations << organisation unless applicant.reload.organisation_ids.include?(organisation.id)
      end

      def remove_applicant_from_organisation
        applicant.delete_organisation(organisation) if applicant.reload.organisation_ids.include?(organisation.id)
        SoftDeleteApplicantJob.perform_async(rdv_solidarites_user_id) if applicant.reload.organisations.empty?
      end
    end
  end
end
