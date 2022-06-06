module RdvSolidaritesWebhooks
  class ProcessOrganisationJob < ApplicationJob
    def perform(data, meta)
      @data = data.deep_symbolize_keys
      @meta = meta.deep_symbolize_keys
      return if organisation.blank?
      return unless event == "updated"

      update_organisation
    end

    private

    def event
      @meta[:event]
    end

    def rdv_solidarites_organisation_id
      @data[:id]
    end

    def organisation
      @organisation ||= Organisation.find_by(rdv_solidarites_organisation_id: rdv_solidarites_organisation_id)
    end

    def update_organisation
      UpsertRecordJob.perform_async("Organisation", @data, { last_webhook_update_received_at: @meta[:timestamp] })
    end
  end
end
