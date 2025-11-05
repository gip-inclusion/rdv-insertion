module MatomoConcern
  extend ActiveSupport::Concern
  include MatomoHelper

  included do
    before_action :set_matomo_tracking_data, if: -> { request.get? }
  end

  private

  def set_matomo_tracking_data
    @enable_matomo_tracking = EnvironmentsHelper.production_env? && logged_in? && current_agent.tracking_accepted?

    return unless @enable_matomo_tracking

    cookies[:matomo_page_url] = matomo_page_url
  end
end
