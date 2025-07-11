class Organisations::RgpdCleanup < BaseService
  def initialize(organisation:)
    @organisation = organisation
    @date_limit = organisation.data_retention_duration.months.ago
  end

  def call
    process_inactive_users # process users for rgpd reasons (destroy or remove from org)
    destroy_useless_rdvs # destroying users will destroy participations ; rdvs with no participations are useless for us
    destroy_useless_notifications
  end

  private

  def process_inactive_users
    inactive_users = find_inactive_users
    return if inactive_users.empty?

    users_to_delete, users_to_remove_from_org = categorize_inactive_users(inactive_users)

    process_users_to_delete(users_to_delete)
    process_users_to_remove_from_org(users_to_remove_from_org)
  end

  def find_inactive_users
    Users::ActivityChecker.call(organisation: @organisation).inactive_users
  end

  def categorize_inactive_users(inactive_users)
    users_to_delete = []
    users_to_remove_from_org = []

    inactive_users.each do |user|
      remove_user_from_current_organisation(user)

      if user.organisations.reload.empty?
        users_to_delete << user
      else
        users_to_remove_from_org << user
      end
    end

    [users_to_delete, users_to_remove_from_org]
  end

  def remove_user_from_current_organisation(user)
    user.users_organisations.find_by!(organisation: @organisation).destroy
  end

  def process_users_to_delete(users_to_delete)
    return if users_to_delete.empty?

    cleanup_user_data(users_to_delete)
    notify_user_deletions(users_to_delete.pluck(:id))
  end

  def process_users_to_remove_from_org(users_to_remove_from_org)
    return if users_to_remove_from_org.empty?

    notify_user_removals(users_to_remove_from_org.pluck(:id))
  end

  def cleanup_user_data(users)
    # this will also destroy participations and invitations
    users.each do |user|
      user.mark_for_rgpd_destruction
      user.destroy!
    end
  end

  def notify_user_deletions(user_ids)
    MattermostClient.send_to_notif_channel(
      "🚮 Les usagers suivants ont été supprimés pour inactivité dans l'organisation " \
      "#{@organisation.name} : #{user_ids.join(', ')}"
    )
  end

  def notify_user_removals(user_ids)
    MattermostClient.send_to_notif_channel(
      "↩️ Les usagers suivants ont été retirés de l'organisation " \
      "#{@organisation.name} pour inactivité (mais restent actifs ailleurs) : #{user_ids.join(', ')}"
    )
  end

  def destroy_useless_rdvs
    useless_rdvs = find_useless_rdvs
    return if useless_rdvs.empty?

    configure_webhooks_for_department_thirteen(useless_rdvs)
    useless_rdvs.destroy_all
    notify_rdv_deletions(useless_rdvs.pluck(:id))
  end

  def find_useless_rdvs
    Rdv.where.missing(:participations)
       .where(organisation: @organisation)
       .where(rdvs: { created_at: ...@date_limit })
  end

  def configure_webhooks_for_department_thirteen(rdvs)
    # We don't send rgpd cleanup webhooks for rdvs in the department 13
    return unless @organisation.department.number == "13"

    rdvs.each do |rdv|
      rdv.should_send_webhook = false
    end
  end

  def notify_rdv_deletions(rdv_ids)
    MattermostClient.send_to_notif_channel(
      "🚮 Les rdvs suivants ont été supprimés automatiquement pour l'organisation " \
      "#{@organisation.name} : #{rdv_ids.join(', ')}"
    )
  end

  def destroy_useless_notifications
    # notifications with no participation_id are useless code-wise, so we can clean them manually
    useless_notifications = Notification.joins(
      "JOIN rdvs ON rdvs.rdv_solidarites_rdv_id = notifications.rdv_solidarites_rdv_id"
    )
                                        .where(participation_id: nil)
                                        .where(created_at: ...@date_limit)
                                        .where(rdvs: { organisation_id: @organisation.id })

    return if useless_notifications.empty?

    useless_notifications_ids = useless_notifications.pluck(:id)
    useless_notifications.destroy_all

    MattermostClient.send_to_notif_channel(
      "🚮 Les notifications suivantes ont été supprimées automatiquement pour l'organisation " \
      "#{@organisation.name} : #{useless_notifications_ids.join(', ')}"
    )
  end
end
