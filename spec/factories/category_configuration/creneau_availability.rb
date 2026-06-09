FactoryBot.define do
  factory :creneau_availability, class: "CategoryConfiguration::CreneauAvailability" do
    number_of_creneaux_available { rand(0..30) }
    category_configuration
  end
end
