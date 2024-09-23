module InboundWebhooks
  module RdvSolidarites
    class ProcessOrganisationJob < ApplicationJob
      def perform(data, meta)
        @data = data.deep_symbolize_keys
        @meta = meta.deep_symbolize_keys
        return if organisation.blank?
        return if event == "destroyed"

        send_invalid_verticale_to_sentry unless verticale_is_valid?
        update_organisation
      end

      private

      def send_invalid_verticale_to_sentry
        Sentry.capture_message(
          "Verticale attribute is not valid for rdv_solidarites_organisation_id : #{rdv_solidarites_organisation_id}"
        )
      end

      def verticale_is_valid?
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
        UpsertRecordJob.perform_later("Organisation", @data, { last_webhook_update_received_at: @meta[:timestamp] })
      end
    end
  end
end
