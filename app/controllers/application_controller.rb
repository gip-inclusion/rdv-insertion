class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_sentry_context

  include AuthorizationConcern
  include AuthenticatedControllerConcern
  include BeforeActionOverride

  private

  def set_sentry_context
    Sentry.set_user(sentry_user)
  end

  def sentry_user
    {
      id: current_agent&.id,
      email: current_agent&.email
    }.compact
  end

  def page
    params[:page] || 1
  end

  def department_level?
    params[:department_id].present?
  end

  def production_env?
    ENV["SENTRY_ENVIRONMENT"] == "production"
  end
end
