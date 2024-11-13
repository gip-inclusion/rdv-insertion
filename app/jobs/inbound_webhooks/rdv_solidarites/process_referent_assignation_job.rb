module InboundWebhooks
  module RdvSolidarites
    class ProcessReferentAssignationJob < LockedAndOrderedJobBase
      def self.lock_key(data, _meta)
        "Lock::#{name}:#{data.dig(:agent, :id)}:#{data.dig(:user, :id)}"
      end

      def perform(data, meta)
        @data = data.deep_symbolize_keys
        @meta = meta.deep_symbolize_keys
        # if webhook_reason is rgpd we want to keep the relation to be able to recreate it on rdvs if necessary
        return if user.blank? || agent.blank? || webhook_reason == "rgpd"

        attach_agent_to_user if event == "created"
        remove_agent_from_user if event == "destroyed"
      end

      private

      def event
        @meta[:event]
      end

      def webhook_reason
        @meta[:webhook_reason]
      end

      def rdv_solidarites_user_id
        @data[:user][:id]
      end

      def rdv_solidarites_agent_id
        @data[:agent][:id]
      end

      def user
        @user ||= User.find_by(rdv_solidarites_user_id: rdv_solidarites_user_id)
      end

      def agent
        @agent ||= Agent.find_by(rdv_solidarites_agent_id: rdv_solidarites_agent_id)
      end

      def attach_agent_to_user
        ReferentAssignation.find_or_create_by!(agent:, user:)
      end

      def remove_agent_from_user
        return unless user.reload.referent_ids.include?(agent.id)

        user.referents.delete(agent)
      end
    end
  end
end
