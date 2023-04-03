class WebhookEndpoint < ApplicationRecord
  ALL_SUBSCRIPTIONS = %w[rdv user user_profile organisation motif lieu agent agent_role referent_assignation].freeze

  has_and_belongs_to_many :organisations
end
