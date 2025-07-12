FactoryBot.define do
  factory :super_admin_authentication_request do
    agent { create(:agent, :super_admin) }
    token { SecureRandom.alphanumeric(6).upcase }
  end
end
