module InboundWebhooks
  module RdvSolidarites
    class ProcessOrganisationJob < ApplicationJob
      def perform(data, meta)
        @data = data.deep_symbolize_keys
        @meta = meta.deep_symbolize_keys
        return if organisation.blank?
        return if event == "destroyed"

        return send_invalid_verticale_to_third_party_tools unless verticale_is_valid?

        update_organisation
      end

      private

      def send_invalid_verticale_to_third_party_tools
        Sentry.capture_message(
          "Verticale attribute is not valid for rdv_solidarites_organisation_id : #{rdv_solidarites_organisation_id}"
        )
        MattermostClient.send_to_main_channel(
          "La verticale de l'organisation avec ID rdvs #{rdv_solidarites_organisation_id} n'est pas valide."
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
        UpsertRecordJob.perform_async("Organisation", @data, { last_webhook_update_received_at: @meta[:timestamp] })
      end
    end
  end
end
