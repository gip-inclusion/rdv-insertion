class Users::ActivityChecker < BaseService
  def initialize(organisation:)
    @organisation = organisation
    @date_limit = @organisation.data_retention_duration.months.ago
  end

  def call
    find_inactive_users
  end

  def user_has_recent_activity?(user)
    !find_inactive_users.exists?(id: user.id)
  end

  def find_inactive_users
    @organisation.users.left_outer_joins(:invitations,
                                         :participations,
                                         :users_organisations,
                                         :tag_users,
                                         :referent_assignations)
                 .where(users: { created_at: ...@date_limit })
                 .where(invitations_not_recent_condition)
                 .where(participations_not_recent_condition)
                 .where(tag_users_not_recent_condition)
                 .where(referent_assignations_not_recent_condition)
                 .distinct
  end

  private

  def invitations_not_recent_condition
    ["NOT EXISTS (
      SELECT 1
      FROM invitations
      WHERE invitations.user_id = users.id AND invitations.created_at >= ?
    )", @date_limit]
  end

  def participations_not_recent_condition
    ["NOT EXISTS (
      SELECT 1
      FROM participations
      WHERE participations.user_id = users.id AND participations.created_at >= ?
    )", @date_limit]
  end

  def tag_users_not_recent_condition
    ["NOT EXISTS (
      SELECT 1
      FROM tag_users
      WHERE tag_users.user_id = users.id AND tag_users.created_at >= ?
    )", @date_limit]
  end

  def referent_assignations_not_recent_condition
    ["NOT EXISTS (
      SELECT 1
      FROM referent_assignations
      WHERE referent_assignations.user_id = users.id AND referent_assignations.created_at >= ?
    )", @date_limit]
  end
end
