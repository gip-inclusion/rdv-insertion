FactoryBot.define do
  factory :creneaux_snapshot, class: "UserListUpload::CreneauxSnapshot" do
    user_list_upload
    number_of_creneaux_available { 50 }
  end
end
