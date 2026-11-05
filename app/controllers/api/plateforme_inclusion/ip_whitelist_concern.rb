require "ipaddr"

module Api::PlateformeInclusion::IpWhitelistConcern
  extend ActiveSupport::Concern

  # IP list comes from the outboundIPs of the Paris zone
  # https://api.clever-cloud.com/v4/products/zones/par
  IP_WHITELIST_RANGES = [
    "46.252.181.0/24",
    "91.208.207.0/24",
    "185.42.117.0/24",
    "185.133.116.0/22"
  ].freeze

  private

  def ensure_ip_comes_from_clever_cloud
    # In case Clever Cloud decides to use some other IP range without notice
    # we need a quick way to skip this check
    return if ENV["DISABLE_PLATEFORME_INCLUSION_IP_WHITELIST"].present?

    return if IP_WHITELIST_RANGES.any? { |range| IPAddr.new(range).include?(request.remote_ip) }

    Sentry.capture_message(
      "Plateforme de l'inclusion search with a valid token from a non whitelisted IP",
      extra: { ip: request.remote_ip }
    )
    render json: { errors: ["Cette adresse IP n'est pas autorisée"] }, status: :forbidden
  end
end
