module NotificationCenterConcern
  extend ActiveSupport::Concern

  MOTIF_SHORT_NAMES_FOR_WHICH_NOTIFICATION_CENTER_IS_SHOWN = [:rsa_accompagnement, :rsa_orientation,
                                                              :rsa_orientation_france_travail].freeze

  included do
    before_action :set_has_important_unread_notifications, if: :show_notification_center?
    helper_method :most_recent_notification_read, :oldest_notification_read, :notification_read?,
                  :show_notification_center?
  end

  private

  def set_has_important_unread_notifications
    @has_important_unread_notifications = CreneauAvailability
                                          .joins(category_configuration: :motif_category)
                                          .where(category_configuration: { organisation_id: current_organisation_id })
                                          .where(motif_category: {
                                                   short_name: MOTIF_SHORT_NAMES_FOR_WHICH_NOTIFICATION_CENTER_IS_SHOWN
                                                 })
                                          .where(created_at: most_recent_notification_read...)
                                          # If organisation has 2 valid motif_categories it will receive 2 notifications
                                          # Any of the notifications created today may be important, not just the last
                                          .where(created_at: Time.zone.today...)
                                          .with_pending_invitations
                                          .order(created_at: :desc)
                                          .any?(&:low_availability?)
  end

  def most_recent_notification_read
    Time.zone.at(cookies["most_recent_notification_read_on_#{current_organisation_id}"].to_i)
  end

  def oldest_notification_read
    Time.zone.at(
      cookies["oldest_notification_read_on_#{current_organisation_id}"]&.to_i || Time.zone.now.strftime("%s%L").to_i
    )
  end

  def notification_read?(notification)
    notification.created_at.to_i <= most_recent_notification_read.to_i &&
      notification.created_at.to_i >= oldest_notification_read.to_i
  end

  def show_notification_center?
    @show_notification_center ||=
      will_request_load_header_partial_on_organisation_scoped_page? &&
      logged_in? &&
      organisation_has_expected_motifs_for_notification_center?
  end

  def will_request_load_header_partial_on_organisation_scoped_page?
    return false unless request.get? && !turbo_frame_request? && !request.xhr?

    params[:organisation_id].present?
  end

  def organisation_has_expected_motifs_for_notification_center?
    current_organisation
      .motif_categories
      .exists?(short_name: MOTIF_SHORT_NAMES_FOR_WHICH_NOTIFICATION_CENTER_IS_SHOWN)
  end
end
