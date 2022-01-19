FactoryBot.define do
  factory :invitation do
    token { "some_token" }
    link { "https://www.rdv_solidarites.com/some_params" }
    format { :sms }
    department { create(:department) }
    association :applicant
    help_phone_number { "0139393939" }
    # rubocop:disable RSpec/EmptyExampleGroup, RSpec/MissingExampleGroupArgument
    context { "RSA orientation" }
    # rubocop:enable RSpec/EmptyExampleGroup, RSpec/MissingExampleGroupArgument

    after(:build) do |invitation|
      next if invitation.organisations.present?

      invitation.department_id = invitation.department.id
      invitation.organisations << create(:organisation, department: invitation.department)
    end
  end
end
