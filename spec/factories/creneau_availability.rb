FactoryBot.define do
  factory :creneau_availability do
    number_of_creneaux_available { rand(0..30) }
    category_configuration
  end
end
