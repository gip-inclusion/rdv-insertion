class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :exception

  include AuthenticatedControllerConcern

  private

  def department_id
    params[:id] || params[:department_id]
  end
end
