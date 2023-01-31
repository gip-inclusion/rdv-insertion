module RdvSolidaritesWebhooks
  class ProcessMotifJob < ApplicationJob
    def perform(data, meta)
      @data = data.deep_symbolize_keys
      @meta = meta.deep_symbolize_keys
      return if organisation.blank?

      upsert_motif
    end

    private

    def rdv_solidarites_organisation_id
      @data[:organisation_id]
    end

    def rdv_solidarites_motif
      RdvSolidarites::Motif.new(@data)
    end

    def motif_category
      @motif_category ||= MotifCategory.find_by(short_name: rdv_solidarites_motif.motif_category&.short_name)
    end

    def organisation
      @organisation ||= Organisation.find_by(rdv_solidarites_organisation_id: rdv_solidarites_organisation_id)
    end

    def upsert_motif
      UpsertRecordJob.perform_async(
        "Motif",
        rdv_solidarites_motif.to_rdv_insertion_attributes,
        {
          organisation_id: organisation.id,
          last_webhook_update_received_at: @meta[:timestamp]
        }
          .merge(motif_category ? { motif_category_id: motif_category.id } : {})
      )
    end
  end
end
