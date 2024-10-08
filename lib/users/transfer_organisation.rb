module Users
  class TransferOrganisation
    attr_reader :source_organisation, :target_organisation, :source_motif_category, :errors

    def initialize(source_organisation_id:, target_organisation_id:, source_motif_category_id:)
      @source_organisation = Organisation.find(source_organisation_id)
      @target_organisation = Organisation.find(target_organisation_id)
      @source_motif_category = MotifCategory.find(source_motif_category_id)
      @errors = []
    end

    def call
      set_current_agent
      each_matching_user do |user|
        transfer_to_target_organisation(user)
        remove_from_source_organisation(user) 
      rescue => error
        errors << { user:, error: }
      end
    end

    private

    def each_matching_user
      UsersOrganisation
        .joins(user: :follow_ups)
        .where(follow_ups: { motif_category: source_motif_category })
        .where.not(follow_ups: { status: "closed" })
        .where(organisation: source_organisation)
        .find_each do |user_organisation|
        yield user_organisation.user
      end
    end

    def set_current_agent
      Current.agent = source_organisation.agents.take
    end

    def transfer_to_target_organisation(user)
      service = Users::Save.call(user:, organisation: target_organisation)
      raise "Unable to transfer to target organisation" unless service.success?
    end

    def remove_from_source_organisation(user)
      service = Users::RemoveFromOrganisation.call(user:, organisation: source_organisation)
      raise "Unable to remove from source organisation" unless service.success?
    end
  end
end
