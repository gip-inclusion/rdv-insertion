module RdvSolidarites
  class WebhookEndpoint < Base
    RECORD_ATTRIBUTES = [
      :id, :target_url, :secret, :subscriptions, :organisation_id
    ].freeze

    ALL_SUBSCRIPTIONS = %w[rdv user user_profile organisation motif lieu agent agent_role referent_assignation].freeze

    attr_reader(*RECORD_ATTRIBUTES)
  end
end
