class DestroyOldRessourcesJob < ApplicationJob
  def perform
    destroy_inactive_users # destroy users for rgpd reasons
    destroy_useless_rdvs # destroying users will destroy participations ; rdvs with no participations are useless for us
    destroy_useless_notifications
  end

  private

  def destroy_inactive_users # rubocop:disable Metrics/MethodLength
    # this will also destroy participations and invitations
    # we check the orgs because being added to an organisation is a sign that the user is in an active process
    inactive_users =
      User.left_outer_joins(:invitations, :participations, :users_organisations)
          .where(users: { created_at: ...date_limit })
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

    inactive_users.find_each(&:mark_for_rgpd_destruction)

    inactive_user_ids = inactive_users.pluck(:id)

    inactive_users.destroy_all

    MattermostClient.send_to_notif_channel(
      "🚮 Les usagers suivants ont été supprimés pour inactivité : " \
      "#{inactive_user_ids.join(', ')}"
    )
  end

  def destroy_useless_rdvs
    useless_rdvs = Rdv.where.missing(:participations).where(rdvs: { created_at: ...date_limit })

    # On envoit pas de webhook de destroy rgpd pour les rdvs du département 13
    bdr_rdv_ids = useless_rdvs.joins(organisation: :department)
                              .where(departments: { number: "13" })
                              .pluck(:id)
    useless_rdvs.each do |rdv|
      next unless rdv.id.in?(bdr_rdv_ids)

      rdv.should_send_webhook = false
    end

    useless_rdvs.destroy_all

    MattermostClient.send_to_notif_channel(
      "🚮 Les rdvs suivants ont été supprimés automatiquement : " \
      "#{useless_rdvs.pluck(:id).join(', ')}"
    )
  end

  def destroy_useless_notifications
    # notifications with no participation_id are useless code-wise, so we can clean them manually
    useless_notifications = Notification.where(participation_id: nil).where(created_at: ...date_limit).destroy_all

    MattermostClient.send_to_notif_channel(
      "🚮 Les notifications suivantes ont été supprimées automatiquement : " \
      "#{useless_notifications.pluck(:id).join(', ')}"
    )
  end

  def date_limit
    2.years.ago
  end
end
