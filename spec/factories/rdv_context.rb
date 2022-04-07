FactoryBot.define do
  factory :rdv_context do
    association :applicant
    # rubocop:disable RSpec/EmptyExampleGroup, RSpec/MissingExampleGroupArgument
    context { "rsa_orientation" }
    # rubocop:enable RSpec/EmptyExampleGroup, RSpec/MissingExampleGroupArgument

    after(:build) do |a|
      # https://github.com/thoughtbot/factory_bot/issues/931#issuecomment-307542965
      a.class.skip_callback(:save, :before, :set_status, raise: false)
    end
  end
end
