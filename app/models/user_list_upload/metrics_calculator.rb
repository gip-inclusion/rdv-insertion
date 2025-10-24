class UserListUpload::MetricsCalculator
  attr_reader :user_list_upload, :processing_log

  delegate :user_saves_triggered_at, :user_saves_started_at, :user_saves_ended_at,
           :invitations_triggered_at, :invitations_started_at, :invitations_ended_at,
           to: :processing_log, allow_nil: true

  def initialize(user_list_upload)
    @user_list_upload = user_list_upload
    @processing_log = user_list_upload.processing_log
  end

  def time_between_user_saves_triggered_and_user_saves_ended
    user_saves_ended_at - user_saves_triggered_at if user_saves_ended_at && user_saves_triggered_at
  end

  def time_between_user_saves_triggered_and_user_saves_started
    user_saves_started_at - user_saves_triggered_at if user_saves_started_at && user_saves_triggered_at
  end

  def time_between_user_saves_started_and_user_saves_ended
    user_saves_ended_at - user_saves_started_at if user_saves_ended_at && user_saves_started_at
  end

  def time_between_user_saves_started_and_user_saves_ended_per_user_row
    return unless time_between_user_saves_started_and_user_saves_ended
    return if number_of_rows_selected_for_user_save.zero?

    time_between_user_saves_started_and_user_saves_ended / number_of_rows_selected_for_user_save
  end

  def time_between_invitations_triggered_and_invitations_started
    invitations_started_at - invitations_triggered_at if invitations_started_at && invitations_triggered_at
  end

  def time_between_invitations_triggered_and_invitations_ended
    invitations_ended_at - invitations_triggered_at if invitations_ended_at && invitations_triggered_at
  end

  def time_between_invitations_started_and_invitations_ended
    invitations_ended_at - invitations_started_at if invitations_ended_at && invitations_started_at
  end

  def time_between_invitations_started_and_invitations_ended_per_user_row
    return unless time_between_invitations_started_and_invitations_ended
    return if number_of_rows_selected_for_invitation.zero?

    time_between_invitations_started_and_invitations_ended / number_of_rows_selected_for_invitation
  end

  def rate_of_selected_rows_for_user_save
    percentage(number_of_rows_selected_for_user_save, total_number_of_rows)
  end

  def rate_of_selected_rows_for_invitation
    percentage(number_of_rows_selected_for_invitation, total_number_of_rows)
  end

  def rate_of_user_saves_succeeded
    percentage(number_of_successful_user_saves, number_of_user_saves)
  end

  def rate_of_invitations_succeeded
    percentage(number_of_successful_invitations, number_of_invitation_attempts)
  end

  def rate_of_saved_users
    percentage(number_of_users_saved, total_number_of_rows)
  end

  def rate_of_invited_users
    percentage(number_of_users_invited, total_number_of_rows)
  end

  def to_h
    {
      time_between_user_saves_triggered_and_user_saves_ended:,
      time_between_user_saves_triggered_and_user_saves_started:,
      time_between_user_saves_started_and_user_saves_ended:,
      time_between_user_saves_started_and_user_saves_ended_per_user_row:,
      time_between_invitations_triggered_and_invitations_started:,
      time_between_invitations_triggered_and_invitations_ended:,
      time_between_invitations_started_and_invitations_ended:,
      time_between_invitations_started_and_invitations_ended_per_user_row:,
      rate_of_selected_rows_for_user_save:,
      rate_of_selected_rows_for_invitation:,
      rate_of_user_saves_succeeded:,
      rate_of_invitations_succeeded:,
      rate_of_saved_users:,
      rate_of_invited_users:
    }
  end

  private

  def total_number_of_rows
    @total_number_of_rows ||= user_list_upload.user_rows.count
  end

  def number_of_rows_selected_for_user_save
    @number_of_rows_selected_for_user_save ||= user_list_upload.user_rows_selected_for_user_save.count
  end

  def number_of_rows_selected_for_invitation
    @number_of_rows_selected_for_invitation ||= user_list_upload.user_rows_selected_for_invitation.count
  end

  def number_of_users_saved
    @number_of_users_saved ||= user_list_upload.user_rows_with_user_save_success.count
  end

  def number_of_users_invited
    @number_of_users_invited ||= user_list_upload.user_rows_with_successful_invitation.count
  end

  def number_of_user_saves
    @number_of_user_saves ||= user_list_upload.user_save_attempts.count
  end

  def number_of_invitation_attempts
    @number_of_invitation_attempts ||= user_list_upload.invitation_attempts.count
  end

  def number_of_successful_user_saves
    @number_of_successful_user_saves ||= user_list_upload.user_save_attempts.count(&:success?)
  end

  def number_of_successful_invitations
    @number_of_successful_invitations ||= user_list_upload.invitation_attempts.count(&:success?)
  end

  def percentage(numerator, denominator)
    return nil if denominator.zero?

    (numerator / denominator.to_f * 100).round(2)
  end
end
