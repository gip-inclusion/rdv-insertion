module AuthenticatedControllerConcern
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
    helper_method :logged_in?
  end

  private

  def clear_session
    session.delete(:department_id)
    @current_department = nil
  end

  def authenticate_user!
    redirect_to sign_in_path(department_id: department_id) unless logged_in?
  end

  def current_department?(department)
    department == current_department
  end

  def logged_in?
    !current_department.nil?
  end

  def current_department
    @current_department ||= Department.find_by(id: session[:department_id])
  end

  # we are dealing with current_department instead of current_user and we have
  # to specify it to pundit
  def pundit_user
    current_department
  end

  def user_not_authorized
    flash[:alert] = "Votre compte ne vous permet pas d'effectuer cette action"
    redirect_to(request.referrer || root_path)
  end
end
