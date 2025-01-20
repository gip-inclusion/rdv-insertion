FactoryBot.define do
  factory :invitation_attempt, class: "UserListUpload::InvitationAttempt" do
    user_row
    invitation
    success { true }
    service_errors { [] }
    error_type { nil }
    internal_error_message { nil }
    format { "email" }
  end
end
