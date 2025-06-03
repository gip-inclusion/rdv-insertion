require "ipaddr"

module Brevo::IpWhitelistConcern
  extend ActiveSupport::Concern

  # IP list comes from
  # https://help.brevo.com/hc/en-us/articles/15127404548498-Brevo-IP-ranges-List-of-publicly-exposed-services#h_01HENC062K8KJKJE7BJNYMPM77
  IP_WHITELIST_RANGES = [
    "1.179.112.0/20",
    "172.246.240.0/20"
  ].freeze

  included do
    before_action :ensure_ip_comes_from_brevo_ips
  end

  private

  def ensure_ip_comes_from_brevo_ips
    # In case Brevo decides to use some other IP range without notice
    # we need a quick way to skip this check
    return if ENV["DISABLE_BREVO_IP_WHITELIST"].present?

    return if IP_WHITELIST_RANGES.any? { |range| IPAddr.new(range).include?(request.remote_ip) }

    Sentry.capture_message("Brevo Webhook received with following non whitelisted IP", {
                             extra: {
                               ip: request.remote_ip
                             }
                           })
    head :forbidden
  end
end
