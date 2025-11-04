FactoryBot.define do
  factory :user_row, class: "UserListUpload::UserRow" do
    user_list_upload
    cnaf_data { {} }
    first_name { "John" }
    last_name { "Doe" }
    email { "john.doe@example.com" }
    affiliation_number { "1234567890" }
    role { "demandeur" }
    title { "monsieur" }
  end

  trait :not_selected_for_user_save do
    after(:create) do |user_row|
      # we need to do it in an update since it is set automatically when the user_row is created
      user_row.update_column(:selected_for_user_save, false)
    end
  end
end
