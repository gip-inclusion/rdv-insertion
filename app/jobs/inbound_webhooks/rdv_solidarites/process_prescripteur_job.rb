module InboundWebhooks
  module RdvSolidarites
    class ProcessPrescripteurJob < ApplicationJob
      def perform(data, meta)
        @data = data.deep_symbolize_keys
        @meta = meta.deep_symbolize_keys
        return if participation.blank?

        upsert_or_delete_prescripteur
      end

      private

      def event
        @meta[:event]
      end

      def rdv_solidarites_prescripteur_id
        @data[:id]
      end

      def participation
        @participation ||= Participation.find_by(rdv_solidarites_participation_id: @data[:participation_id])
      end

      def upsert_or_delete_prescripteur
        return delete_prescripteur if event == "destroyed"

        UpsertRecordJob.perform_async(
          "Prescripteur",
          @data,
          { last_webhook_update_received_at: @meta[:timestamp], participation_id: participation.id }
        )
      end

      def delete_prescripteur
        prescripteur = Prescripteur.find_by(rdv_solidarites_prescripteur_id: rdv_solidarites_prescripteur_id)
        prescripteur.destroy!
      end
    end
  end
end
