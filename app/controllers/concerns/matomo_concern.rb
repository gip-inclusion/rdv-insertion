module MatomoConcern
  extend ActiveSupport::Concern
  include MatomoHelper

  included do
    before_action :set_enable_matomo_tracking, if: -> { request.get? }
    before_action :set_matomo_page_url_cookie, if: :matomo_tracking_enabled? && request.get?
  end

  private

  def set_enable_matomo_tracking
    @enable_matomo_tracking = matomo_tracking_enabled?
  end

  def set_matomo_page_url_cookie
    cookies[:matomo_page_url] = matomo_page_url
  end

  def matomo_tracking_enabled?
    EnvironmentsHelper.production_env? && logged_in? && current_agent.tracking_accepted?
  end
end
