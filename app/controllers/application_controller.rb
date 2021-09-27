class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :exception
  before_action :set_sentry_context

  include AuthenticatedControllerConcern

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

  def rdv_solidarites_session
    session[:rdv_solidarites]
  end

  def json_request?
    request.format == "application/json"
  end

  def page
    params[:page] || 1
  end
end
