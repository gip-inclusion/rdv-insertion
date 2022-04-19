FactoryBot.define do
  factory :invitation do
    token { "some_token" }
    link { "https://www.rdv_solidarites.com/some_params" }
    format { :sms }
    number_of_days_to_accept_invitation { 3 }
    department { create(:department) }
    association :applicant
    help_phone_number { "0139393939" }
    rdv_context { build(:rdv_context) }
    after(:build) do |invitation|
      next if invitation.organisations.present?

      invitation.department_id = invitation.department.id
      invitation.organisations << create(:organisation, department: invitation.department)
    end
  end
end
