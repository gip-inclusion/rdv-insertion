class UserListUpload::InvitationAttempt
  def self.create(user_row:, format:)
    invite_user_result = InviteUser.call(
      user: user_row.saved_user,
      organisations: user_row.user_list_upload.organisations,
      motif_category_attributes: { id: user_row.user_list_upload.motif_category_id },
      invitation_attributes: { format: format }
    )
  rescue StandardError => e
    invite_user_result = OpenStruct.new(success?: false, errors: [e.message])
  ensure
    (user_row.row_data[:invitation_attempts] ||= []).push(
      created_at: Time.current,
      success: invite_user_result.success?,
      errors: invite_user_result.errors,
      format: format,
      invitation_id: invite_user_result.invitation&.id
    )
  end

  attr_reader :created_at, :success, :errors, :format, :invitation_id
  alias_method :success?, :success

  def initialize(created_at:, success:, errors:, format:, invitation_id:)
    @created_at = created_at
    @success = success
    @errors = errors
    @format = format
    @invitation_id = invitation_id
  end
end
