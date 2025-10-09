module Agent::CookiesConsentable
  extend ActiveSupport::Concern

  included do
    has_one :cookies_consent, dependent: :destroy
  end

  def support_accepted?
    (cookies_consent&.persisted? && cookies_consent.support_accepted?) || false
  end

  def tracking_accepted?
    (cookies_consent&.persisted? && cookies_consent.tracking_accepted?) || false
  end
end
