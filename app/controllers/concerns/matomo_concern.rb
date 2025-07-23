module MatomoConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_enable_matomo_tracking, if: -> { request.get? }
  end

  private

  def set_enable_matomo_tracking
    @enable_matomo_tracking = EnvironmentsHelper.production_env? && logged_in? && current_agent.tracking_accepted?
  end
end
