FactoryBot.define do
  factory :lieu do
    sequence(:rdv_solidarites_lieu_id) { |n| n + Process.pid }
    name { "DINUM" }
    address { "20 avenue de Ségur 75007 Paris" }
    organisation
  end
end
