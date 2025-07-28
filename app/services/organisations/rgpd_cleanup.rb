class Organisations::RgpdCleanup < BaseService
  def initialize(organisation:, dry_run:)
    @organisation = organisation
    @date_limit = organisation.data_retention_duration_in_months.months.ago
    @dry_run = dry_run
  end

  def call
    ActiveRecord::Base.transaction do
      # remove from org and destroy if no orgs left
      process_inactive_users
      # destroying users will destroy participations ; rdvs with no participations are useless for us
      destroy_useless_rdvs
      raise ActiveRecord::Rollback if @dry_run
    end
  end

  private

  def process_inactive_users
    inactive_users = @organisation.inactive_users
    return if inactive_users.empty?

    remove_users_from_org(inactive_users)

    users_to_delete, users_to_remove_from_org = inactive_users.partition { |user| user.reload.organisations.empty? }

    process_users_to_delete(users_to_delete)
    notify_user_removals(users_to_remove_from_org.pluck(:id))
  end

  def remove_users_from_org(users)
    users.each do |user|
      remove_user_from_current_organisation(user)
    end
  end

  def remove_user_from_current_organisation(user)
    user.users_organisations.find_by!(organisation: @organisation).destroy
  end

  def process_users_to_delete(users_to_delete)
    return if users_to_delete.empty?

    destroy_users(users_to_delete)
    notify_user_deletions(users_to_delete.pluck(:id))
  end

  def destroy_users(users)
    # this will also destroy participations and invitations
    users.each do |user|
      user.mark_for_rgpd_destruction
      user.destroy!
    end
  end

  def notify_user_deletions(user_ids)
    MattermostClient.send_to_rgpd_cleanup_channel(
      "#{dry_run_log_prefix}🚮 Les usagers suivants ont été supprimés pour inactivité dans l'organisation " \
      "#{@organisation.name} : #{user_ids.join(', ')}"
    )
    Rails.logger.info("#{dry_run_log_prefix}🚮 Les usagers suivants ont été supprimés pour inactivité dans " \
                      "l'organisation #{@organisation.name} : #{user_ids.join(', ')}")
  end

  def notify_user_removals(user_ids)
    return if user_ids.empty?

    MattermostClient.send_to_rgpd_cleanup_channel(
      "#{dry_run_log_prefix}↩️ Les usagers suivants ont été retirés de l'organisation " \
      "#{@organisation.name} pour inactivité (mais restent actifs ailleurs) : #{user_ids.join(', ')}"
    )
    Rails.logger.info(
      "#{dry_run_log_prefix}↩️ Les usagers suivants ont été retirés de l'organisation " \
      "#{@organisation.name} pour inactivité (mais restent actifs ailleurs) : #{user_ids.join(', ')}"
    )
  end

  def destroy_useless_rdvs
    useless_rdvs = find_useless_rdvs
    return if useless_rdvs.empty?

    useless_rdvs_ids = useless_rdvs.pluck(:id)

    do_not_send_destroy_webhooks_for_rdvs(useless_rdvs)
    useless_rdvs.destroy_all
    notify_rdv_deletions(useless_rdvs_ids)
  end

  def find_useless_rdvs
    Rdv.where.missing(:participations)
       .where(organisation: @organisation)
       .where(rdvs: { created_at: ...@date_limit })
  end

  def do_not_send_destroy_webhooks_for_rdvs(rdvs)
    # We assume external services have their own way to handle RGDP data retention
    rdvs.each { |rdv| rdv.should_send_webhook = false }
  end

  def notify_rdv_deletions(rdv_ids)
    MattermostClient.send_to_rgpd_cleanup_channel(
      "#{dry_run_log_prefix}🚮 Les rdvs suivants ont été supprimés automatiquement pour l'organisation " \
      "#{@organisation.name} : #{rdv_ids.join(', ')}"
    )
    Rails.logger.info(
      "#{dry_run_log_prefix}🚮 Les rdvs suivants ont été supprimés automatiquement pour l'organisation " \
      "#{@organisation.name} : #{rdv_ids.join(', ')}"
    )
  end

  def dry_run_log_prefix
    @dry_run ? "[🔍 DRY RUN] " : ""
  end
end
