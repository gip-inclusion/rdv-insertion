FactoryBot.define do
  factory :user_list_upload do
    agent
    structure { create(:department) }
    category_configuration
  end
end
