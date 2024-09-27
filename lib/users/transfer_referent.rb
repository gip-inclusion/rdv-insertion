module Users
  class TransferReferent
    attr_reader :source_referent, :target_referent, :errors

    def initialize(source_referent_id:, target_referent_id:)
      @source_referent = Agent.find(source_referent_id)
      @target_referent = Agent.find(target_referent_id)
      @errors = []
    end

    def call
      ReferentAssignation.includes(user: :organisations).where(agent: source_referent).each do |referent_assignation|
        ActiveRecord::Base.transaction do
          set_current_agent(referent_assignation)
          assign_target_and_remove_source_referent(referent_assignation)
        end
      end

      if errors.any?
        puts "Les usagers suivants n'ont pas pu être transférés : #{errors.map { |e| e[:user].id }.join(', ')}"
      else
        puts "Tous les usagers ont été transférés avec succès"
      end
    end

    private

    def set_current_agent(referent_assignation)
      Current.agent = referent_assignation.agent
    end

    def assign_target_and_remove_source_referent(referent_assignation)
      assignation_service = Users::AssignReferent.call(user: referent_assignation.user, agent: target_referent)

      if assignation_service.success?
        remove_source_referent(referent_assignation)
      else
        @errors << { error: assignation_service.error, user: referent_assignation.user }
      end
    end

    def remove_source_referent(referent_assignation)
      remove_service = Users::RemoveReferent.call(user: referent_assignation.user, agent: source_referent)

      if !remove_service.success?
        @errors << { error: remove_service.error, user: referent_assignation.user }
        raise ActiveRecord::Rollback
      end
    end
  end
end
