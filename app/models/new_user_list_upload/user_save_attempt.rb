module NewUserListUpload
  class UserSaveAttempt < ApplicationRecord
    belongs_to :user_row, class_name: "NewUserListUpload::UserRow"
    belongs_to :user, optional: true

    def self.create_from_row(user_row:)
      save_user_result = UserListUpload::SaveUser.call(user_row: user_row)
    rescue StandardError => e
      save_user_result = OpenStruct.new(success?: false, errors: [e.message], error_type: e.class.name.underscore)
    ensure
      user_row.user_save_attempts.create!(
        created_at: Time.current,
        success: save_user_result.success?,
        service_errors: save_user_result.errors,
        error_type: save_user_result.error_type,
        user_id: save_user_result.user&.id
      )
    end

    def no_organisation_to_assign?
      error_type == "no_organisation_to_assign"
    end
  end
end
