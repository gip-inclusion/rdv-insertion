module RdvSolidaritesWebhooks
  class ProcessLieuJob < ApplicationJob
    def perform(data, meta)
      @data = data.deep_symbolize_keys
      @meta = meta.deep_symbolize_keys
      return if organisation.blank?

      upsert_lieu
    end

    private

    def rdv_solidarites_organisation_id
      @data[:organisation_id]
    end

    def organisation
      @organisation ||= Organisation.find_by(rdv_solidarites_organisation_id: rdv_solidarites_organisation_id)
    end

    def upsert_lieu
      UpsertRecordJob.perform_async(
        "Lieu",
        @data,
        { organisation_id: organisation.id, last_webhook_update_received_at: @meta[:timestamp] }
      )
    end
  end
end
