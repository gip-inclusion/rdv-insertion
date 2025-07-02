module NotificationCenterConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_has_important_unread_notifications, if: :show_notification_center?
    helper_method :notifications_read_at, :notification_read?,
                  :show_notification_center?
  end

  private

  def set_has_important_unread_notifications
    @has_important_unread_notifications = CreneauAvailability
                                          .with_rsa_related_motif
                                          .joins(:category_configuration)
                                          .where(category_configuration: { organisation_id: current_organisation_id })
                                          .where(category_configuration: { rdv_with_referents: false })
                                          .where(created_at: notifications_read_at...)
                                          # If organisation has 2 valid motif_categories it will receive 2 notifications
                                          # Any of the notifications created today may be important, not just the last
                                          .where(created_at: Time.zone.today...)
                                          .with_pending_invitations
                                          .order(created_at: :desc)
                                          .any?(&:low_availability?)
  end

  def notifications_read_at
    Time.zone.at(
      cookies["notifications_read_at_on_org_id_#{current_organisation_id}"].to_i
    )
  end

  def notification_read?(notification)
    notification.created_at.to_i <= notifications_read_at.to_i
  end

  def show_notification_center?
    @show_notification_center ||=
      will_request_load_header_partial_on_organisation_scoped_page? &&
      logged_in? &&
      organisation_has_expected_motifs_for_notification_center?
  end

  def will_request_load_header_partial_on_organisation_scoped_page?
    request.get? && !turbo_frame_request? && !request.xhr? && params[:organisation_id].present?
  end

  def organisation_has_expected_motifs_for_notification_center?
    current_organisation
      .category_configurations
      .where(rdv_with_referents: false)
      .joins(:motif_category)
      .exists?(motif_categories: { motif_category_type: MotifCategory::RSA_RELATED_TYPES })
  end
end
