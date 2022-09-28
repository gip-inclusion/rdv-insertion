class WebhookProcessingJobError < StandardError; end

module RdvSolidaritesWebhooks
  # rubocop:disable Metrics/ClassLength
  class ProcessRdvJob < ApplicationJob
    def perform(data, meta)
      @data = data.deep_symbolize_keys
      @meta = meta.deep_symbolize_keys
      verify_organisation!
      verify_motif!
      return if applicants.empty?
      return if unhandled_category?

      verify_lieu!
      upsert_or_delete_rdv
      invalidate_related_invitations if event == "created"
      notify_applicants if should_notify_applicants?
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

    def verify_lieu!
      return if @data[:lieu].blank?
      return if rdv_solidarites_lieu == lieu

      raise WebhookProcessingJobError, "Lieu in webhook is not the same as the one in db: #{@data[:lieu]}"
    end

    def should_notify_applicants?
      matching_configuration.notify_applicant? && event.in?(%w[created destroyed])
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

    def rdv_solidarites_rdv
      RdvSolidarites::Rdv.new(@data)
    end

    def rdv_solidarites_user_ids
      rdv_solidarites_rdv.user_ids
    end

    def applicants
      @applicants ||= Applicant.where(rdv_solidarites_user_id: rdv_solidarites_user_ids)
    end

    def applicant_ids
      applicants.pluck(:id)
    end

    def related_invitations
      @related_invitations ||= Invitation.where(rdv_context_id: rdv_context_ids)
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

    def upsert_or_delete_rdv
      if event == "destroyed"
        DeleteRdvJob.perform_async(rdv_solidarites_rdv.id)
      else
        UpsertRecordJob.perform_async(
          "Rdv",
          @data,
          {
            applicant_ids: applicant_ids,
            organisation_id: organisation.id,
            motif_id: motif.id,
            rdv_context_ids: rdv_context_ids,
            last_webhook_update_received_at: @meta[:timestamp]
          }
          .merge(lieu.present? ? { lieu_id: lieu.id } : {})
          .merge(rdv_convocable? ? { convocable: true } : {})
        )
      end
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

    def notify_applicants
      applicants.each do |applicant|
        NotifyApplicantJob.perform_async(
          applicant.id,
          organisation.id,
          @data,
          event
        )
      end
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
