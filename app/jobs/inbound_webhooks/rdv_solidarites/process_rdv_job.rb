class WebhookProcessingJobError < StandardError; end

module InboundWebhooks
  module RdvSolidarites
    # rubocop:disable Metrics/ClassLength
    class ProcessRdvJob < ApplicationJob
      def perform(data, meta)
        @data = data.deep_symbolize_keys
        @meta = meta.deep_symbolize_keys

        Rdv.with_advisory_lock("processing_rdv_#{rdv_solidarites_rdv.id}") do
          verify_organisation!
          verify_motif!
          return if unhandled_category?

          find_or_create_users

          # for a convocation, we have to verify the lieu is up to date in db
          verify_lieu_sync! if convocable_participations?
          upsert_or_delete_rdv
          invalidate_related_invitations if created_event?
          send_outgoing_webhooks
        end
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

      def matching_configuration
        organisation.configurations.find_by(motif_category: motif_category)
      end

      def motif_category
        @motif_category ||= MotifCategory.find_by(short_name: rdv_solidarites_motif_category&.short_name)
      end

      def unhandled_category?
        rdv_solidarites_motif_category.nil? || motif_category.nil? || matching_configuration.nil?
      end

      def event
        @meta[:event]
      end

      def rdv_solidarites_lieu
        ::RdvSolidarites::Lieu.new(@data[:lieu])
      end

      def rdv_solidarites_motif_category
        rdv_solidarites_rdv.motif_category
      end

      def created_event?
        event == "created"
      end

      def rdv_solidarites_rdv
        ::RdvSolidarites::Rdv.new(@data)
      end

      def rdv
        @rdv ||= Rdv.find_by(rdv_solidarites_rdv_id: rdv_solidarites_rdv.id)
      end

      def rdv_solidarites_user_ids
        rdv_solidarites_rdv.user_ids
      end

      def find_or_create_users
        existing_users = User.where(rdv_solidarites_user_id: rdv_solidarites_user_ids).to_a

        new_rdv_solidarites_users = rdv_solidarites_rdv.users.reject do |user|
          user.id.in?(existing_users.map(&:rdv_solidarites_user_id))
        end

        new_users = new_rdv_solidarites_users.map do |user|
          User.create!(
            rdv_solidarites_user_id: user.id,
            organisations: [organisation],
            created_through: "rdv_solidarites",
            **user.attributes.slice(*User::SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES).compact_blank
          )
        end

        @users = existing_users + new_users
      end

      def participations_attributes_destroyed
        return [] if rdv.nil?

        removed_users = rdv.users - @users
        @participations_attributes_destroyed ||=
          removed_users.map do |user|
            existing_participation = Participation.find_by(user: user, rdv: rdv)
            {
              id: existing_participation&.id,
              user_id: user.id,
              _destroy: true
            }
          end.compact
      end

      def participations_attributes
        @participations_attributes ||=
          @users.map do |user|
            compute_participation_attributes(user)
          end.compact + participations_attributes_destroyed
      end

      # rubocop:disable Metrics/AbcSize
      def compute_participation_attributes(user)
        rdv_solidarites_participation = rdv_solidarites_rdv.participations.find do |participation|
          participation.user.id == user.rdv_solidarites_user_id
        end
        existing_participation = rdv&.participation_for(user)

        attributes = {
          id: existing_participation&.id,
          status: rdv_solidarites_participation.status,
          created_by: rdv_solidarites_participation.created_by,
          user_id: user.id,
          rdv_solidarites_participation_id: rdv_solidarites_participation.id,
          rdv_context_id: rdv_context_for(user).id
        }
        # convocable attribute can be set only once
        if existing_participation.nil?
          attributes.merge!(
            convocable: rdv_solidarites_participation.convocable? && matching_configuration.convene_user?
          )
        end
        attributes
      end
      # rubocop:enable Metrics/AbcSize

      def rdv_context_for(user)
        rdv_contexts.find { _1.user_id == user.id }
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
        @lieu ||=
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
              participations_attributes: participations_attributes,
              organisation_id: organisation.id,
              motif_id: motif.id,
              last_webhook_update_received_at: @meta[:timestamp]
            }
            .merge(lieu.present? ? { lieu_id: lieu.id } : {})
          )
        end
      end

      def convocable_participations?
        matching_configuration.convene_user? && rdv_solidarites_rdv.participations.any?(&:convocable?)
      end

      def invalidate_related_invitations
        # We invalidate the invitations linked to the new or updated rdvs to avoid double appointments
        related_invitations
          .joins(rdv_context: :motif_category)
          .where(motif_categories: { participation_optional: false })
          .each do |invitation|
          InvalidateInvitationJob.perform_async(invitation.id)
        end
      end

      def rdv_contexts
        @rdv_contexts ||=
          @users.map do |user|
            RdvContext.with_advisory_lock "setting_rdv_context_for_user_#{user.id}" do
              RdvContext.find_or_create_by!(user: user, motif_category: motif_category)
            end
          end
      end

      def rdv_context_ids
        rdv_contexts.map(&:id)
      end

      def send_outgoing_webhooks
        return if ENV["STOP_SENDING_WEBHOOKS"] == "1"

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
end
