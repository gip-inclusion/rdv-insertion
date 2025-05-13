module Users
  class PartitionUsersByDepartment
    def call
      User.find_each do |user|
        partition_user(user)
      end
    end

    private

    def partition_user(user)
      most_recent_active_organisation = organisation_with_most_recent_activity(user)
      most_recent_active_department = most_recent_active_organisation&.department

      return if most_recent_active_department.blank?

      user.update!(department_id: most_recent_active_department.id)

      # Remove all organisations that are not in the same department
      UsersOrganisation.joins(:organisation)
        .where(user:)
        .where.not(organisations: { department_id: most_recent_active_department.id })
        .destroy_all
    end

    def organisation_with_most_recent_activity(user)
      return user.organisations.first if user.organisations.count <= 1
      most_recent_organisation_addition = UsersOrganisation.where(user:).order(created_at: :desc).first

      most_recent_activity = {
        activity_date: most_recent_organisation_addition.created_at,
        organisation_id: most_recent_organisation_addition.organisation_id,
      }

      most_recent_participation = Participation.where(user:).order(created_at: :desc).first

      if most_recent_participation&.created_at && most_recent_participation.created_at > most_recent_activity[:activity_date]
        most_recent_activity[:activity_date] = most_recent_participation.created_at
        most_recent_activity[:organisation_id] = most_recent_participation.organisation.id
      end

      most_recent_invitation = Invitation.where(user:).order(created_at: :desc).first

      if most_recent_invitation&.created_at && most_recent_invitation.created_at > most_recent_activity[:activity_date]
        most_recent_activity[:activity_date] = most_recent_invitation.created_at
        most_recent_activity[:organisation_id] = most_recent_invitation.organisations.first.id
      end

      Organisation.find(most_recent_activity[:organisation_id])
    end
  end
end
