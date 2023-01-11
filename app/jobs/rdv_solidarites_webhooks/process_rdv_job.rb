class WebhookProcessingJobError < StandardError; end

module RdvSolidaritesWebhooks
  # rubocop:disable Metrics/ClassLength
  class ProcessRdvJob < ApplicationJob
    def perform(data, meta)
      @data = data.deep_symbolize_keys
      @meta = meta.deep_symbolize_keys
      verify_organisation!
      verify_motif!
      return if empty_applicants_on_new_rdv?
      return if unhandled_category?

      # for a convocation, we have to verify the lieu is up to date in db
      verify_lieu_sync! if rdv_convocable?
      upsert_or_delete_rdv
      invalidate_related_invitations if created_event?
      send_outgoing_webhooks
    end

    private

    def verify_organisation!
      return if organisation

      raise WebhookProcessingJobError, "Organisation not found with id #{rdv_solidarites_organisation_id}"
    end

    def verify_motif!
      return if motif

      raise WebhookProcessingJobError, "Motif not found with id #{rdv_solidarites_motif_id}"
    end

    def verify_lieu_sync!
      return unless rdv_solidarites_rdv.presential?
      return if @data[:lieu].present? && rdv_solidarites_lieu == lieu

      raise WebhookProcessingJobError, "Lieu in webhook is not coherent. #{@data[:lieu]}"
    end

    def empty_applicants_on_new_rdv?
      applicants.empty? && rdv.nil?
    end

    def matching_configuration
      organisation.configurations.find_by(motif_category: rdv_solidarites_rdv.category)
    end

    # Category is checked through the webhook directly and not through the motif we have in DB since it's always
    # more reliable than our cache
    def unhandled_category?
      Motif.categories.keys.exclude?(rdv_solidarites_rdv.category) || matching_configuration.nil?
    end

    def event
      @meta[:event]
    end

    def rdv_solidarites_lieu
      RdvSolidarites::Lieu.new(@data[:lieu])
    end

    def created_event?
      event == "created"
    end

    def rdv_solidarites_rdv
      RdvSolidarites::Rdv.new(@data)
    end

    def rdv
      @rdv ||= Rdv.find_by(rdv_solidarites_rdv_id: rdv_solidarites_rdv.id)
    end

    def rdv_solidarites_user_ids
      rdv_solidarites_rdv.user_ids
    end

    def applicants
      @applicants ||= Applicant.where(rdv_solidarites_user_id: rdv_solidarites_user_ids)
    end

    def participations_attributes_destroyed
      return [] if rdv.nil?

      removed_applicants = rdv.applicants - applicants
      @participations_attributes_destroyed ||= \
        removed_applicants.map do |applicant|
          existing_participation = Participation.find_by(applicant: applicant, rdv: rdv)
          {
            id: existing_participation&.id,
            applicant_id: applicant.id,
            _destroy: true
          }
        end.compact
    end

    def participations_attributes
      @participations_attributes ||= \
        @applicants.map do |applicant|
          participation = rdv_solidarites_rdv.participations.find { _1.user.id == applicant.rdv_solidarites_user_id }
          {
            id: existing_participation_for(applicant)&.id,
            status: participation.status,
            applicant_id: applicant.id,
            rdv_solidarites_participation_id: participation.id,
            rdv_context_id: rdv_context_for(applicant).id
          }
        end.compact + participations_attributes_destroyed
    end

    def existing_participation_for(applicant)
      rdv.nil? ? nil : Participation.find_by(applicant: applicant, rdv: rdv)
    end

    def rdv_context_for(applicant)
      rdv_contexts.find { _1.applicant_id == applicant.id }
    end

    def related_invitations
      @related_invitations ||= Invitation.sent.valid.where(rdv_context_id: rdv_context_ids)
    end

    def organisation
      @organisation ||= Organisation.find_by(rdv_solidarites_organisation_id: rdv_solidarites_organisation_id)
    end

    def motif
      @motif ||= Motif.find_by(rdv_solidarites_motif_id: rdv_solidarites_motif_id)
    end

    def lieu
      @lieu ||= \
        @data[:lieu].present? ? Lieu.find_by(rdv_solidarites_lieu_id: @data[:lieu][:id]) : nil
    end

    def rdv_solidarites_motif_id
      rdv_solidarites_rdv.motif_id
    end

    def rdv_solidarites_organisation_id
      @data[:organisation][:id]
    end

    def delete_rdv?
      # Destroy event or Emptied rdv
      event == "destroyed" || (applicants.empty? && rdv.present?)
    end

    def upsert_or_delete_rdv
      if delete_rdv?
        DeleteRdvJob.perform_async(rdv_solidarites_rdv.id)
      else
        UpsertRecordJob.perform_async(
          "Rdv",
          @data,
          {
            participations_attributes: participations_attributes,
            organisation_id: organisation.id,
            motif_id: motif.id,
            last_webhook_update_received_at: @meta[:timestamp]
          }
          .merge(lieu.present? ? { lieu_id: lieu.id } : {})
          .merge(set_convocable_attribute? ? { convocable: true } : {})
        )
      end
    end

    def set_convocable_attribute?
      # we only set the convocation during rdv creation
      created_event? && rdv_convocable?
    end

    def rdv_convocable?
      matching_configuration.convene_applicant? && rdv_solidarites_rdv.convocable?
    end

    def invalidate_related_invitations
      # We invalidate the invitations linked to the new or updated rdvs to avoid double appointments
      related_invitations.each do |invitation|
        InvalidateInvitationJob.perform_async(invitation.id)
      end
    end

    def rdv_contexts
      @rdv_contexts ||= \
        applicants.map do |applicant|
          RdvContext.with_advisory_lock "setting_rdv_context_for_applicant_#{applicant.id}" do
            RdvContext.find_or_create_by!(applicant: applicant, motif_category: matching_configuration.motif_category)
          end
        end
    end

    def rdv_context_ids
      rdv_contexts.map(&:id)
    end

    def send_outgoing_webhooks
      organisation.webhook_endpoints.each do |webhook_endpoint|
        SendRdvSolidaritesWebhookJob.perform_async(webhook_endpoint.id, outgoing_webhook_payload)
      end
    end

    def outgoing_webhook_payload
      {
        data: @data.merge(users: rdv_solidarites_rdv.users.map(&:augmented_attributes)),
        meta: @meta
      }
    end
  end
  # rubocop:enable Metrics/ClassLength
end
