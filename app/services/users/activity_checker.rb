class Users::ActivityChecker < BaseService
  def initialize(organisation:)
    @organisation = organisation
    @date_limit = @organisation.data_retention_duration.months.ago
  end

  def call
    result.inactive_users = find_inactive_users
  end

  def find_inactive_users
    @organisation.users.where(users: { created_at: ...@date_limit })
                 .where(invitations_not_recent_condition)
                 .where(participations_not_recent_condition)
                 .where(tag_users_not_recent_condition)
                 .where(referent_assignations_not_recent_condition)
  end

  private

  def invitations_not_recent_condition
    ["NOT EXISTS (
      SELECT 1
      FROM invitations
      JOIN invitations_organisations ON invitations.id = invitations_organisations.invitation_id
      WHERE invitations.user_id = users.id
        AND invitations.created_at >= ?
        AND invitations_organisations.organisation_id = ?
    )", @date_limit, @organisation.id]
  end

  def participations_not_recent_condition
    ["NOT EXISTS (
      SELECT 1
      FROM participations
      JOIN rdvs ON participations.rdv_id = rdvs.id
      WHERE participations.user_id = users.id
        AND participations.created_at >= ?
        AND rdvs.organisation_id = ?
    )", @date_limit, @organisation.id]
  end

  def tag_users_not_recent_condition
    ["NOT EXISTS (
      SELECT 1
      FROM tag_users
      JOIN tags ON tag_users.tag_id = tags.id
      JOIN tag_organisations ON tags.id = tag_organisations.tag_id
      WHERE tag_users.user_id = users.id
        AND tag_users.created_at >= ?
        AND tag_organisations.organisation_id = ?
    )", @date_limit, @organisation.id]
  end

  def referent_assignations_not_recent_condition
    ["NOT EXISTS (
      SELECT 1
      FROM referent_assignations
      JOIN agents ON referent_assignations.agent_id = agents.id
      JOIN agent_roles ON agents.id = agent_roles.agent_id
      WHERE referent_assignations.user_id = users.id
        AND referent_assignations.created_at >= ?
        AND agent_roles.organisation_id = ?
    )", @date_limit, @organisation.id]
  end
end
