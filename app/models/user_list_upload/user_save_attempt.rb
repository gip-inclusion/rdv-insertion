class UserListUpload::UserSaveAttempt < ApplicationRecord
  belongs_to :user_row, class_name: "UserListUpload::UserRow"
  belongs_to :user, optional: true

  def self.create_from_row(user_row:)
    save_user_result = UserListUpload::SaveUser.call(user_row: user_row)
  rescue StandardError => e
    save_user_result = OpenStruct.new(
      success?: false,
      errors: ["Une erreur est survenue lors de la sauvegarde de l'usager."],
      error_type: e.class.name.underscore,
      internal_error_message: e.detailed_message
    )
    Sentry.capture_exception(e)
  ensure
    user_row.user_save_attempts.create!(
      success: save_user_result.success?,
      service_errors: save_user_result.errors,
      error_type: save_user_result.error_type,
      user_id: save_user_result.user&.id,
      internal_error_message: save_user_result.internal_error_message
    )
  end

  def no_organisation_to_assign?
    error_type == "no_organisation_to_assign"
  end

  def error?
    !success?
  end
end
