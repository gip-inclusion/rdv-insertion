module InboundWebhooks
  module RdvSolidarites
    class ProcessReferentAssignationJob < ApplicationJob
      def perform(data, meta)
        @data = data.deep_symbolize_keys
        @meta = meta.deep_symbolize_keys
        return if user.blank? || agent.blank?

        User.with_advisory_lock "assigning_#{rdv_solidarites_agent_id}_to_#{rdv_solidarites_user_id}" do
          attach_agent_to_user if event == "created"
          remove_agent_from_user if event == "destroyed"
        end
      end

      private

      def event
        @meta[:event]
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
        return if user.reload.referent_ids.include?(agent.id)

        user.referents << agent
      end

      def remove_agent_from_user
        return unless user.reload.referent_ids.include?(agent.id)

        user.referents.delete(agent)
      end
    end
  end
end
