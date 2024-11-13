module InboundWebhooks
  module RdvSolidarites
    class ProcessAgentRoleJob < LockedAndOrderedJobBase
      def self.lock_key(data, _meta)
        "#{base_lock_key}:#{data.dig(:agent, :id)}:#{data.dig(:organisation, :id)}"
      end

      def perform(data, meta)
        @data = data.deep_symbolize_keys
        @meta = meta.deep_symbolize_keys

        return if organisation.blank? || @data[:access_level] == "intervenant"

        # This is necessary when the agent role has been created through rdv-i without the rdv-s record
        # when importing an organisation
        assign_rdv_solidarites_agent_role_id if agent_role
        event == "destroyed" ? remove_agent_from_org : upsert_agent_role
      end

      private

      def upsert_agent_role
        return if agent_attributes.blank?

        upsert_agent! if agent.nil?

        UpsertRecordJob.perform_later(
          "AgentRole",
          @data,
          { organisation_id: organisation.id, agent_id: agent.id, last_webhook_update_received_at: @meta[:timestamp] }
        )
      end

      def remove_agent_from_org
        agent_role&.destroy! # we first destroy the agent role record
        return if agent.blank?

        # we ensure the agent is removed from the org in case agent role record wasn't found
        agent.organisations.delete(organisation)
        delete_agent if agent.reload.organisations.empty?
      end

      def delete_agent
        agent.destroy!
        MattermostClient.send_to_notif_channel(
          "agent removed from organisation #{organisation.name} (#{organisation.id}) and deleted"
        )
      end

      def upsert_agent!
        raise "Could not upsert agent #{agent_attributes}" unless upsert_agent.success?
      end

      def upsert_agent
        @upsert_agent ||= UpsertRecord.call(
          klass: Agent,
          rdv_solidarites_attributes: @data[:agent],
          additional_attributes: { last_webhook_update_received_at: @meta[:timestamp] }
        )
      end

      def assign_rdv_solidarites_agent_role_id
        agent_role.update!(rdv_solidarites_agent_role_id: @data[:id]) if agent_role.rdv_solidarites_agent_role_id.nil?
      end

      def event
        @meta[:event]
      end

      def rdv_solidarites_agent_role_id
        @data[:id]
      end

      def rdv_solidarites_agent_id
        @data[:agent][:id]
      end

      def agent_attributes
        @data[:agent]
      end

      def rdv_solidarites_organisation_id
        @data[:organisation][:id]
      end

      def organisation
        @organisation ||= Organisation.find_by(rdv_solidarites_organisation_id: rdv_solidarites_organisation_id)
      end

      def agent
        @agent ||= Agent.find_by(rdv_solidarites_agent_id: rdv_solidarites_agent_id)
      end

      def agent_role
        @agent_role ||= AgentRole.find_by(organisation_id: organisation.id, agent_id: agent&.id)
      end
    end
  end
end
