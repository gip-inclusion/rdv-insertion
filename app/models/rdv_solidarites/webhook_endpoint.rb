module RdvSolidarites
  class WebhookEndpoint < Base
    RECORD_ATTRIBUTES = [
      :id, :target_url, :secret, :subscriptions, :organisation_id
    ].freeze
    attr_reader(*RECORD_ATTRIBUTES)
  end
end
