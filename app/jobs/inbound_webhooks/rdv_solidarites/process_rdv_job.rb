class WebhookProcessingJobError < StandardError; end

module InboundWebhooks
  module RdvSolidarites
    # rubocop:disable Metrics/ClassLength
    class ProcessRdvJob < LockedAndOrderedJobBase
      def self.lock_key(data, _meta)
        "#{base_lock_key}:#{data[:id]}"
      end

      def self.on_lock_failure(data, _meta)
        DeduplicateRdvSolidaritesWebhooksFromRetrySetJob.perform_later(name, data[:id])
      end

      def perform(data, meta)
        @data = data.deep_symbolize_keys
        @meta = meta.deep_symbolize_keys

        if event == "destroyed"
          delete_or_nullify_rdv
        else
          process_rdv
        end
      end

      private

      def process_rdv
        verify_organisation!
        return if unhandled_category?

        verify_motif!

        find_or_create_users

        # for a convocation, we have to verify the lieu is up to date in db
        verify_lieu_sync! if convocable_participations?
        upsert_rdv
        invalidate_related_invitations if created_event?
      end

      def delete_or_nullify_rdv
        if webhook_reason == "rgpd"
          NullifyRdvSolidaritesIdJob.perform_later("Rdv", rdv&.id)
        else
          DeleteRdvJob.perform_later(rdv_solidarites_rdv.id)
        end
      end

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
        organisation.category_configurations.find_by(motif_category: motif_category)
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

      def webhook_reason
        @meta[:webhook_reason]
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

      def agents
        @agents ||= Agent.where(rdv_solidarites_agent_id: @data[:agents].to_a.pluck(:id))
      end

      def rdv_solidarites_user_ids
        rdv_solidarites_rdv.user_ids
      end

      # rubocop:disable Metrics/AbcSize
      def find_or_create_users
        # rdv users that already exist in db
        existing_users = User.where(rdv_solidarites_user_id: rdv_solidarites_user_ids).to_a
        # rdv users that have been previously deleted
        previously_deleted_users = User.where(old_rdv_solidarites_user_id: rdv_solidarites_user_ids).to_a

        new_rdv_solidarites_users = rdv_solidarites_rdv.users.select do |user|
          !user.id.in?(existing_users.map(&:rdv_solidarites_user_id)) &&
            # if we process this webhook after a user has been deleted, we should not re-create it
            !user.id.in?(previously_deleted_users.map(&:old_rdv_solidarites_user_id))
        end

        new_users = new_rdv_solidarites_users.map do |rdv_solidarites_user|
          User.create!(
            rdv_solidarites_user_id: rdv_solidarites_user.id,
            created_through: "rdv_solidarites_webhook",
            created_from_structure: organisation,
            organisations: [organisation],
            **rdv_solidarites_user.to_rdvi_attributes.slice(*User::SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES).compact_blank
          )
        end

        @users = existing_users + new_users
      end
      # rubocop:enable Metrics/AbcSize

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

      def compute_participation_attributes(user)
        rdv_solidarites_participation = rdv_solidarites_rdv.participation_for(user)
        existing_participation = rdv&.participation_for(user)
        attributes = {
          id: existing_participation&.id,
          status: rdv_solidarites_participation.status,
          created_by_type: rdv_solidarites_participation.created_by_type,
          rdv_solidarites_created_by_id: rdv_solidarites_participation.created_by_id,
          created_by_agent_prescripteur: rdv_solidarites_participation.created_by_agent_prescripteur,
          user_id: user.id,
          rdv_solidarites_participation_id: rdv_solidarites_participation.id,
          follow_up_id: follow_up_for(user).id
        }

        # convocable attribute can be set only once
        if existing_participation.nil?
          attributes[:convocable] = rdv_solidarites_participation.convocable? && matching_configuration.convene_user?
        end

        attributes
      end

      def follow_up_for(user)
        follow_ups.find { _1.user_id == user.id }
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

      def upsert_rdv
        UpsertRecordJob.perform_later(
          "Rdv",
          @data,
          {
            participations_attributes: participations_attributes,
            agent_ids: agents.ids,
            organisation_id: organisation.id,
            motif_id: motif.id,
            last_webhook_update_received_at: @meta[:timestamp]
          }
          .merge(lieu.present? ? { lieu_id: lieu.id } : {})
        )
      end

      def convocable_participations?
        matching_configuration.convene_user? && rdv_solidarites_rdv.participations.any?(&:convocable?)
      end

      def invitations_to_invalidate
        # we don't invalidate invitations when the participation is optional
        @invitations_to_invalidate ||= Invitation.valid.expireable.where(follow_up_id: follow_up_ids)
      end

      def invalidate_related_invitations
        invitations_to_invalidate.each { |invitation| ExpireInvitationJob.perform_later(invitation.id) }
      end

      def follow_ups
        @follow_ups ||=
          @users.map do |user|
            FollowUp.with_advisory_lock "setting_follow_up_for_user_#{user.id}" do
              FollowUp.find_or_create_by!(user: user, motif_category: motif_category)
            end
          end
      end

      def follow_up_ids
        follow_ups.map(&:id)
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
