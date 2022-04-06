FactoryBot.define do
  factory :configuration do
    sheet_name { 'LISTE DEMANDEURS' }
    invitation_formats { %w[sms] }
    # rubocop:disable RSpec/EmptyExampleGroup, RSpec/MissingExampleGroupArgument
    context { "rsa_orientation" }
    # rubocop:enable RSpec/EmptyExampleGroup, RSpec/MissingExampleGroupArgument
  end
end
