class UserListUpload::UserSaveAttempt
  def self.create(user_row:)
    save_user_result = UserListUpload::SaveUser.call(user_row: user_row)
  rescue StandardError => e
    save_user_result = OpenStruct.new(success?: false, errors: [e.message], error_type: e.class.name.underscore)
  ensure
    (user_row.row_data[:user_save_attempts] ||= []).push(
      created_at: Time.current,
      success: save_user_result.success?,
      errors: save_user_result.errors,
      error_type: save_user_result.error_type,
      user_id: save_user_result.user&.id
    )
  end

  attr_reader :created_at, :success, :errors, :error_type, :user_id
  alias_method :success?, :success

  def initialize(created_at:, success:, errors:, error_type:, user_id:)
    @created_at = Time.zone.parse(created_at)
    @success = success
    @errors = errors
    @error_type = error_type
    @user_id = user_id
  end

  def no_organisation_to_assign?
    error_type == "no_organisation_to_assign"
  end
end
