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
end
