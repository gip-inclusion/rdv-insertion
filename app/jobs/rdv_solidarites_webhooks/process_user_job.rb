module RdvSolidaritesWebhooks
  class ProcessUserJob < ApplicationJob
    def perform(data, meta)
      @data = data.deep_symbolize_keys
      @meta = meta.deep_symbolize_keys
      return if applicant.blank?

      remove_affiliation_number_from_payload if affiliation_number.blank?
      upsert_or_delete_applicant
    end

    private

    def event
      @meta[:event]
    end

    def rdv_solidarites_user_id
      @data[:id]
    end

    def affiliation_number
      @data[:affiliation_number]
    end

    def applicant
      @applicant ||= Applicant.find_by(rdv_solidarites_user_id: rdv_solidarites_user_id)
    end

    # if the affiliation number is nil in RDV-S following a user fusion, we cannot update to nil
    # in RDV-I because we need it to keep it for the uid
    def remove_affiliation_number_from_payload
      @data.delete(:affiliation_number)
    end

    def upsert_or_delete_applicant
      if event == "destroyed"
        SoftDeleteApplicantJob.perform_async(rdv_solidarites_user_id)
      else
        UpsertRecordJob.perform_async("Applicant", @data, { last_webhook_update_received_at: @meta[:timestamp] })
      end
    end
  end
end
