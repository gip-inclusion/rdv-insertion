module InboundWebhooks
  module RdvSolidarites
    class ProcessLieuJob < ApplicationJob
      def perform(data, meta)
        @data = data.deep_symbolize_keys
        @meta = meta.deep_symbolize_keys
        return if organisation.blank?

        upsert_or_delete_lieu
      end

      private

      def rdv_solidarites_organisation_id
        @data[:organisation_id]
      end

      def event
        @meta[:event]
      end

      def rdv_solidarites_lieu_id
        @data[:id]
      end

      def organisation
        @organisation ||= Organisation.find_by(rdv_solidarites_organisation_id: rdv_solidarites_organisation_id)
      end

      def upsert_or_delete_lieu
        return delete_lieu if event == "destroyed"

        UpsertRecordJob.perform_later(
          "Lieu",
          @data,
          { organisation_id: organisation.id, last_webhook_update_received_at: @meta[:timestamp] }
        )
      end

      def delete_lieu
        lieu = Lieu.find_by(rdv_solidarites_lieu_id: rdv_solidarites_lieu_id)
        lieu.destroy!
      end
    end
  end
end
