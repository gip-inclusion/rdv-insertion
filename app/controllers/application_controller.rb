class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :exception

  include AuthenticatedControllerConcern

  private

  def rdv_solidarites_session
    session[:rdv_solidarites]
  end
end
