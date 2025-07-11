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
                 .where.not(id: users_with_recent_invitations)
                 .where.not(id: users_with_recent_participations)
                 .where.not(id: users_with_recent_tag_assignments)
                 .where.not(id: users_with_recent_referent_assignations)
  end

  private

  def users_with_recent_invitations
    User.joins(invitations: :organisations)
        .where(invitations: { created_at: @date_limit.. })
        .where(organisations: { id: @organisation.id })
        .select(:id)
  end

  def users_with_recent_participations
    User.joins(participations: :rdv)
        .where(participations: { created_at: @date_limit.. })
        .where(rdvs: { organisation: @organisation })
        .select(:id)
  end

  def users_with_recent_tag_assignments
    User.joins(tag_users: { tag: :organisations })
        .where(tag_users: { created_at: @date_limit.. })
        .where(organisations: { id: @organisation.id })
        .select(:id)
  end

  def users_with_recent_referent_assignations
    User.joins(referent_assignations: { agent: :organisations })
        .where(referent_assignations: { created_at: @date_limit.. })
        .where(organisations: { id: @organisation.id })
        .select(:id)
  end
end
