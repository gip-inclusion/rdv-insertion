class WebhookProcessingJobError < StandardError; end

module RdvSolidaritesWebhooks
  class ProcessRdvJob < ApplicationJob
    def perform(data, meta)
      @data = data.deep_symbolize_keys
      @meta = meta.deep_symbolize_keys
      check_organisation!
      return if applicants.empty?
      return if unhandled_category?

      upsert_rdv
      invalidate_invitations if event == "created"
      notify_applicants if should_notify_applicants?
      send_webhooks
    end

    private

    def check_organisation!
      return if organisation

      raise WebhookProcessingJobError, "Organisation not found for organisation id #{rdv_solidarites_organisation_id}"
    end

    def should_notify_applicants?
      matching_configuration.notify_applicant? && event.in?(%w[created destroyed])
    end

    def matching_configuration
      organisation.configurations.find_by(motif_category: rdv_solidarites_rdv.category)
    end

    def unhandled_category?
      Configuration.motif_categories.keys.exclude?(rdv_solidarites_rdv.category) || matching_configuration.nil?
    end

    def event
      @meta[:event]
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

    def rdv_solidarites_organisation_id
      @data[:organisation][:id]
    end

    def upsert_rdv
      UpsertRecordJob.perform_async(
        "Rdv",
        rdv_solidarites_rdv.to_rdv_insertion_attributes,
        {
          applicant_ids: applicant_ids,
          organisation_id: organisation.id,
          rdv_context_ids: rdv_context_ids,
          last_webhook_update_received_at: @meta[:timestamp]
        }
      )
    end

    def invalidate_invitations
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

    def send_webhooks
      organisation.webhook_endpoints.each do |webhook_endpoint|
        SendRdvSolidaritesWebhookJob.perform_async(webhook_endpoint.id, webhook_payload)
      end
    end

    def webhook_payload
      {
        data: @data.merge(users: rdv_solidarites_rdv.users.map(&:augmented_attributes)),
        meta: @meta
      }
    end
  end
end
