module Users
  class PartitionSingleUserJob < ApplicationJob
    def perform(user_id)
      user = User.find(user_id)
      partition_user(user)
    end

    private

    def partition_user(user)
      most_recent_active_organisation = organisation_with_most_recent_activity(user)
      most_recent_active_department = most_recent_active_organisation&.department

      return if most_recent_active_department.blank?

      user.update!(department_id: most_recent_active_department.id)

      return if user.organisations.count <= 1

      # Remove all organisations that are not in the same department
      UsersOrganisation.joins(:organisation)
                       .where(user:)
                       .where.not(organisations: { department_id: most_recent_active_department.id })
                       .destroy_all
    end

    def organisation_with_most_recent_activity(user)
      return user.organisations.first if user.organisations.count <= 1

      most_recent_organisation_addition = UsersOrganisation.where(user:).order(created_at: :desc).first
      most_recent_participation = Participation.where(user:).order(created_at: :desc).first
      most_recent_invitation = Invitation.where(user:).order(created_at: :desc).first

      most_recent_activity = [
        most_recent_organisation_addition,
        most_recent_participation,
        most_recent_invitation
      ].compact.max_by(&:created_at)

      infer_organisation_from_activity(most_recent_activity)
    end

    def infer_organisation_from_activity(activity)
      if activity.respond_to?(:organisation)
        Organisation.find(activity.organisation.id)
      else
        Organisation.find(activity.organisations.first.id)
      end
    end
  end
end
