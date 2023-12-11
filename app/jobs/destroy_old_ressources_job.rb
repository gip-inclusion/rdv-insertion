class DestroyOldRessourcesJob < ApplicationJob
  def perform
    destroy_inactive_users # destroy users for rgpd reasons
    destroy_useless_rdvs # destroying users will destroy participations ; rdvs with no participations are useless for us
    destroy_useless_notifications
  end

  private

  def destroy_inactive_users
    # this will also destroy participations and invitations
    # we check the orgs because being added to an organisation is a sign that the user is in an active process
    User.left_outer_joins(:invitations, :participations, :users_organisations)
        .where("users.created_at < ?", date_limit)
        .where("NOT EXISTS (
                SELECT 1
                FROM invitations
                WHERE invitations.user_id = users.id AND (invitations.created_at >= ?)
            )", date_limit)
        .where("NOT EXISTS (
                SELECT 1
                FROM participations
                WHERE participations.user_id = users.id AND (participations.created_at >= ?)
            )", date_limit)
        .where("NOT EXISTS (
                SELECT 1
                FROM users_organisations
                WHERE users_organisations.user_id = users.id AND (users_organisations.created_at >= ?)
            )", date_limit)
        .distinct
        .destroy_all
  end

  def destroy_useless_rdvs
    Rdv.where.missing(:participations).where("rdvs.created_at < ?", date_limit).destroy_all
  end

  def destroy_useless_notifications
    # notifications have no dependent: :destroy and are useless code-wise, so we can clean them manually
    Notification.where("created_at < ?", date_limit).destroy_all
  end

  def date_limit
    2.years.ago
  end
end
