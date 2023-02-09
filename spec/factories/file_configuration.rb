FactoryBot.define do
  factory :file_configuration do
    sequence(:sheet_name) { |n| "LISTE DEMANDEURS_#{n}" }
  end
end
