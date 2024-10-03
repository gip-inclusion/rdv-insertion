module Users
  class TransferReferent
    attr_reader :source_referent, :target_referent, :errors

    def initialize(source_referent_id:, target_referent_id:)
      @source_referent = Agent.find(source_referent_id)
      @target_referent = Agent.find(target_referent_id)
      @errors = []
    end

    def call
      ReferentAssignation.where(agent: source_referent).find_each do |referent_assignation|
        referent_assignation.agent.with_rdv_solidarites_session do
          assign_target_and_remove_source_referent(referent_assignation)
        end
      end
    end

    private

    def assign_target_and_remove_source_referent(referent_assignation)
      assignation_service = Users::AssignReferent.call(user: referent_assignation.user, agent: target_referent)

      if assignation_service.success?
        remove_source_referent(referent_assignation)
      else
        @errors << { error: { message: assignation_service.error, source: Users::AssignReferent.to_s }, user: referent_assignation.user }
      end
    end

    def remove_source_referent(referent_assignation)
      remove_service = Users::RemoveReferent.call(user: referent_assignation.user, agent: source_referent)

      if !remove_service.success?
        @errors << { error: { message: remove_service.error, source: Users::RemoveReferent.to_s  }, user: referent_assignation.user }
      end
    end
  end
end
