module RdvSolidaritesWebhooks
  class ProcessUserProfileJob < ApplicationJob
    def perform(data, meta)
      @data = data.deep_symbolize_keys
      @meta = meta.deep_symbolize_keys
      return if applicant.blank? || organisation.blank?

      remove_applicant_from_organisation if event == "destroyed"
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

    def remove_applicant_from_organisation
      applicant.delete_organisation(organisation)
      return unless applicant.organisations.empty?

      DeleteApplicantJob.perform_async(rdv_solidarites_user_id)
    end
  end
end
