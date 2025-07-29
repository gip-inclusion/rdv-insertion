class Organisation::UsersRetriever
  def initialize(organisation:)
    @organisation = organisation
    @date_limit = organisation.data_retention_duration_in_months.months.ago
  end

  def inactive_users
    User.joins(:users_organisations)
        .where(users_organisations: { organisation: @organisation, created_at: ...@date_limit })
        .where.not(id: users_with_recent_invitations)
        .where.not(id: users_with_recent_participations)
        .where.not(id: users_with_recent_tag_assignments)
        .where.not(id: users_with_recent_referent_assignations)
        .where.not(id: users_updated_recently)
        .distinct
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
        .where(rdvs: { organisation: @organisation, starts_at: @date_limit.. })
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

  def users_updated_recently
    # versions are created only when important changes are made to the user
    # (e.g. name, email, phone number, etc.), so it's more reliable than checking
    # the user's updated_at field that can be set by any migration or non-human action
    # (e.g. when nullifying the rdv_solidarites_user_id for rgpd reasons)
    User.joins("INNER JOIN versions ON versions.item_type = 'User' AND versions.item_id::bigint = users.id")
        .where(versions: { event: "update", created_at: @date_limit.. })
        .select(:id)
  end
end
