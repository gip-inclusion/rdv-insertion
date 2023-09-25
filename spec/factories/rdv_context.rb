FactoryBot.define do
  factory :rdv_context do
    association :user
    association :motif_category

    after(:build) do |rdv_context|
      # https://github.com/thoughtbot/factory_bot/issues/931#issuecomment-307542965
      rdv_context.class.skip_callback(:save, :before, :set_status, raise: false) if rdv_context.status.present?
    end
  end
end
