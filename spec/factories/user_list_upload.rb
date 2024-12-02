FactoryBot.define do
  factory :user_list_upload do
    user_list { [{ "first_name" => "John", "last_name" => "Doe", "nir" => "1234567890" }] }
    agent
    # rubocop:disable FactoryBot/FactoryAssociationWithStrategy
    structure { create(:department) }
    # rubocop:enable FactoryBot/FactoryAssociationWithStrategy
    category_configuration
  end
end
