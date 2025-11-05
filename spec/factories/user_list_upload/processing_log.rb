FactoryBot.define do
  factory :user_list_upload_processing_log, class: "UserListUpload::ProcessingLog" do
    user_list_upload
  end
end
