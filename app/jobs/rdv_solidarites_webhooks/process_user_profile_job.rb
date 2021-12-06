module RdvSolidaritesWebhooks
  class ProcessUserProfileJob < ApplicationJob
    def perform(data, meta)
      @data = data.deep_symbolize_keys
      @meta = meta.deep_symbolize_keys
      return if applicant.blank? || organisation.blank?

      mark_applicant_as_deleted if event == "destroyed"
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

    def mark_applicant_as_deleted
      if applicant.organisations.length > 1
        applicant.delete_organisation(organisation)
      else
        SoftDeleteApplicantJob.perform_async(rdv_solidarites_user_id)
      end
    end
  end
end
