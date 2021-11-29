module RdvSolidaritesWebhooks
  class ProcessUserJob < ApplicationJob
    def perform(data, meta)
      @data = data.deep_symbolize_keys
      @meta = meta.deep_symbolize_keys
      return if applicant.blank?

      upsert_or_delete_applicant
    end

    private

    def event
      @meta[:event]
    end

    def rdv_solidarites_user_id
      @data[:id]
    end

    def applicant
      @applicant ||= Applicant.find_by(rdv_solidarites_user_id: rdv_solidarites_user_id)
    end

    def upsert_or_delete_applicant
      if event == "destroyed"
        DeleteApplicantJob.perform_async(rdv_solidarites_user_id)
      else
        UpsertRecordJob.perform_async("Applicant", @data)
      end
    end
  end
end
