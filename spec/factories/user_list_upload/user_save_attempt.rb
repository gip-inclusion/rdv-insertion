FactoryBot.define do
  factory :user_save_attempt, class: "UserListUpload::UserSaveAttempt" do
    user_row
    user
    success { true }
    service_errors { [] }
    error_type { nil }
    internal_error_message { nil }
  end
end
