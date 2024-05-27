module CurrentStructure
  extend ActiveSupport::Concern

  included do
    before_action :set_structure_type_in_session, :set_session_organisation_id, :set_session_department_id,
                  :set_current_structure_attributes, :set_current_structure,
                  :set_current_department, :set_current_department_organisations

    helper_method :department_level?, :current_organisation_ids

    delegate :id, to: :current_department, prefix: true
  end

  def set_structure_type_in_session
    return if params[:department_id].nil? && params[:organisation_id].nil?

    session[:structure_type] = params[:organisation_id].present? ? "organisation" : "department"
  end

  def set_session_organisation_id
    if session[:structure_type] == "organisation"
      session[:organisation_id] = params[:organisation_id].to_i if params[:organisation_id]
    else
      session[:organisation_id] = nil
    end
  end

  def set_session_department_id
    if session[:structure_type] == "department"
      session[:department_id] = params[:department_id].to_i if params[:department_id]
    else
      session[:department_id] = nil
    end
  end

  def set_current_structure_attributes
    Current.structure_type = session[:structure_type]
    Current.organisation_id = session[:organisation_id]
    Current.department_id = session[:department_id]
  end

  def set_current_structure
    Current.structure = current_structure
  end

  def set_current_department
    Current.department = current_department
  end

  def set_current_department_organisations
    Current.department_organisations ||= current_department&.organisations & current_agent&.organisations
  end

  def department_level?
    Current.structure_type == "department"
  end

  def current_structure
    return unless Current.department_id || Current.organisation_id

    @current_structure ||=
      department_level? ? Department.find(Current.department_id) : Organisation.find(Current.organisation_id)
  end

  def current_department
    return unless current_structure

    @current_department ||=
      department_level? ? current_structure : current_structure.department
  end

  def current_organisation_ids
    @current_organisation_ids ||=
      department_level? ? current_department.organisation_ids : [Current.organisation_id]
  end

  def current_organisation_id
    Current.organisation_id
  end

  def current_organisations_filter
    if department_level?
      { organisations: { department_id: Current.department_id } }
    else
      { organisations: [Current.organisation_id] }
    end
  end

  def current_organisation_filter
    if department_level?
      { organisation: { department_id: Current.department_id } }
    else
      { organisation_id: Current.organisation_id }
    end
  end
end
