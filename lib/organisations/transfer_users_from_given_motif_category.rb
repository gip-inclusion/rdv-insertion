module Organisations
  class TransferUsersFromGivenMotifCategory
    attr_reader :source_organisation, :target_organisation, :motif_category

    def initialize(source_organisation_id:, target_organisation_id:, motif_category_id:)
      @source_organisation = Organisation.find(source_organisation_id)
      @target_organisation = Organisation.find(target_organisation_id)
      @motif_category = MotifCategory.find(motif_category_id)
    end

    def call
      ActiveRecord::Base.transaction do
        transfer_rdvs
        remove_users_from_source_organisation
        add_users_to_target_organisation!
        remove_old_category_configuration!
      end
    end

    private

    def transfer_rdvs
      follow_ups = FollowUp.where(user: users_to_transfer, motif_category:)

      Rdv.joins(:participations).where(
        participations: { follow_up: follow_ups, user: users_to_transfer },
      ).update_all(organisation_id: target_organisation.id)
    end

    def remove_users_from_source_organisation
      UsersOrganisation.where(
        user: users_to_transfer,
        organisation: source_organisation,
      ).delete_all
    end

    def add_users_to_target_organisation!
      users_to_transfer.each do |user|
        UsersOrganisation.create!(user:, organisation: target_organisation) unless UsersOrganisation.exists?(user:, organisation: target_organisation)
      end
    end

    def remove_old_category_configuration!
      CategoryConfiguration.find_by(organisation: source_organisation, motif_category:).destroy!
    end

    def users_to_transfer
      @users_to_transfer ||= User
            .active
            .distinct
            .joins(:follow_ups, :organisations)
            .where(organisations: source_organisation)
            .where(follow_ups: { motif_category: })
            .to_a
    end
  end
end
