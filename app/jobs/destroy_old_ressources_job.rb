class DestroyOldRessourcesJob < ApplicationJob
  def perform
    destroy_inactive_users # destroy users for rgpd reasons
    destroy_useless_rdvs # destroying users will destroy participations ; rdvs with no notifcations are useless for us
    destroy_useless_notifications
  end

  private

  def destroy_inactive_users
    # this will also destroy participations and invitations
    # we check the orgs because being added to an organisation is a sign that the user is in an active process
    User.left_outer_joins(:invitations, :participations, :users_organisations)
        .where("users.created_at < ?", date_limit)
        .where("invitations.created_at < ? OR invitations.created_at IS NULL", date_limit)
        .where("participations.created_at < ? OR participations.created_at IS NULL", date_limit)
        .where("users_organisations.created_at < ? OR users_organisations.created_at IS NULL", date_limit)
        .distinct
        .destroy_all
  end

  def destroy_useless_rdvs
    Rdv.where.missing(:participations).destroy_all
  end

  def destroy_useless_notifications
    # notifications have no dependent: :destroy and are useless code-wise, so we can clean them manually
    Notification.where("created_at < ?", date_limit).destroy_all
  end

  def date_limit
    2.years.ago
  end
end
