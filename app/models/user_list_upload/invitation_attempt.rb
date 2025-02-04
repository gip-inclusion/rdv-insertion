class UserListUpload::InvitationAttempt < ApplicationRecord
  self.table_name = "invitation_attempts"
  belongs_to :user_row, class_name: "UserListUpload::UserRow"
  belongs_to :invitation, optional: true

  enum :format, { sms: "sms", email: "email" }, prefix: true

  def self.create_from_row(user_row:, format:)
    invite_user_result = InviteUser.call(
      user: user_row.saved_user,
      organisations: user_row.user_list_upload.organisations,
      motif_category_attributes: { id: user_row.user_list_upload.motif_category_id },
      invitation_attributes: { format: format }
    )
  rescue StandardError => e
    invite_user_result = OpenStruct.new(
      success?: false,
      errors: ["Une erreur est survenue lors de l'invitation de l'usager."],
      internal_error_message: e.detailed_message
    )
    Sentry.capture_exception(e)
  ensure
    user_row.invitation_attempts.create!(
      success: invite_user_result.success?,
      service_errors: invite_user_result.errors,
      format: format,
      invitation_id: invite_user_result.invitation&.id,
      internal_error_message: invite_user_result.internal_error_message
    )
  end
end
