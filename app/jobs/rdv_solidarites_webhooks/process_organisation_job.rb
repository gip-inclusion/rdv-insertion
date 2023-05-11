module RdvSolidaritesWebhooks
  class ProcessOrganisationJob < ApplicationJob
    def perform(data, meta)
      @data = data.deep_symbolize_keys
      @meta = meta.deep_symbolize_keys
      return if organisation.blank?
      return if event == "destroyed"

      send_sentry_message_if_verticale_attribute_is_invalid
      update_organisation
    end

    private

    def send_sentry_message_if_verticale_attribute_is_invalid
      return if verticale_attribute_is_valid?

      Sentry.capture_message(
        "Verticale attribute is not valid for rdv_solidarites_organisation_id : #{rdv_solidarites_organisation_id}"
      )
    end

    def verticale_attribute_is_valid?
      @data[:verticale] == "rdv_insertion"
    end

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
