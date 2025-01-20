FactoryBot.define do
  factory :user_list_upload do
    agent
    # rubocop:disable FactoryBot/FactoryAssociationWithStrategy
    structure { create(:department) }
    # rubocop:enable FactoryBot/FactoryAssociationWithStrategy
    category_configuration
  end
end
