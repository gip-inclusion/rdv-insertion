module CurrentStructure
  extend ActiveSupport::Concern

  included do
    before_action :set_structure_type_in_session, :set_session_organisation_id, :set_session_department_id,
                  :set_current_structure_attributes

    helper_method :department_level?
  end

  def set_structure_type_in_session
    return if params[:department_id].nil? && params[:organisation_id].nil?

    session[:structure_type] = params[:organisation_id].present? ? "organisation" : "department"
  end

  def set_session_organisation_id
    if session[:structure_type] == "organisation"
      session[:organisation_id] = params[:organisation_id] if params[:organisation_id]
    else
      session[:organisation_id] = nil
    end
  end

  def set_session_department_id
    if session[:structure_type] == "department"
      session[:department_id] = params[:department_id] if params[:department_id]
    else
      session[:department_id] = nil
    end
  end

  def set_current_structure_attributes
    Current.structure_type = session[:structure_type]
    Current.organisation_id = session[:organisation_id]
    Current.department_id = session[:department_id]
  end

  def department_level?
    Current.structure_type == "department"
  end
end
