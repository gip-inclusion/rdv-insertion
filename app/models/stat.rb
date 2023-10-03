class Stat < ApplicationRecord
  belongs_to :statable, polymorphic: true, optional: true

  def all_users
    @all_users ||= statable.nil? ? User.all : statable.users
  end

  def archived_user_ids
    @archived_user_ids ||=
      if statable.nil?
        User.where.associated(:archives).select(:id).ids
      else
        statable.archived_users.select(:id).ids
      end
  end

  def all_participations
    @all_participations ||= statable.nil? ? Participation.all : statable.participations
  end

  def invitations_sample
    @invitations_sample ||= statable.nil? ? Invitation.sent : statable.invitations.sent
  end

  # We filter the participations to only keep the participations of the users in the scope
  def participations_sample
    @participations_sample ||= all_participations.where(user_id: users_sample)
  end

  # We filter participations to keep only convocations
  def participations_with_notifications_sample
    @participations_with_notifications_sample ||= participations_sample.joins(:notifications).distinct
  end

  # We filter participations to keep only invitations
  def participations_without_notifications_sample
    @participations_without_notifications_sample ||= participations_sample.where.missing(:notifications).distinct
  end

  # We exclude the rdvs collectifs motifs to correctly compute the rate of autonomous users
  def rdvs_non_collectifs_sample
    @rdvs_non_collectifs_sample ||= Rdv.where(motif: Motif.individuel).distinct
  end

  def invited_users_sample
    @invited_users_sample ||= users_sample.with_sent_invitations.distinct
  end

  # We filter the rdv_contexts to keep those where the users were invited and created a rdv/participation
  def rdv_contexts_with_invitations_and_participations_sample
    @rdv_contexts_with_invitations_and_participations_sample ||=
      RdvContext.preload(:participations, :invitations)
                .where(user_id: users_sample)
                .where.associated(:participations)
                .with_sent_invitations
                .distinct
  end

  # We filter the users by organisations and retrieve deleted or archived users
  def users_sample
    @users_sample ||= User.preload(:participations)
                          .joins(:organisations)
                          .where(organisations: organisations_sample)
                          .active
                          .where.not(id: archived_user_ids)
                          .distinct
  end

  # We don't include in the stats the agents working for rdv-insertion
  def agents_sample
    @agents_sample ||= Agent.not_betagouv
                            .joins(:organisations)
                            .where(organisations: all_organisations)
                            .where(has_logged_in: true)
                            .distinct
  end

  def all_organisations
    @all_organisations ||=
      if statable_type == "Organisation"
        Organisation.where(id: statable_id)
      else
        statable.nil? ? Organisation.all : statable.organisations
      end
  end

  # We don't include in the scope the organisations who don't invite the users
  def organisations_sample
    @organisations_sample ||= all_organisations.joins(:configurations)
                                               .where.not(configurations: { invitation_formats: [] })
  end

  # We only consider specific contexts to focus on the first RSA rdv
  def users_with_orientation_category_sample
    @users_with_orientation_category_sample ||=
      users_sample.joins(:rdv_contexts)
                  .where(rdv_contexts: RdvContext.orientation)
  end

  # To compute the rate of users oriented, we only consider the users who have been invited
  # because the users that are directly convocated do not benefit from our added value
  def orientation_rdv_contexts_sample
    @orientation_rdv_contexts_sample ||=
      RdvContext.orientation.preload(:participations, :invitations)
                .where(user: users_sample)
                .with_sent_invitations
                .distinct
  end
end
