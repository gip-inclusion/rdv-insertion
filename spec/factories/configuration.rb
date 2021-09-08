FactoryBot.define do
  factory :configuration do
    sheet_name { 'LISTE DEMANDEURS' }
    invitation_format { :sms }
    association :department
  end
end
