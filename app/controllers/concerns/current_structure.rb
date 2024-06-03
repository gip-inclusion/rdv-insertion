module CurrentStructure
  extend ActiveSupport::Concern

  included do
    before_action :set_current_structure_type, :set_current_organisation_id, :set_current_department_id,
                  :set_current_structure, :set_current_department, :set_current_organisation,
                  :set_current_agent_department_organisations

    helper_method :current_structure_type, :department_level?, :current_organisation_ids, :current_organisation_id,
                  :current_department_id, :current_agent_department_organisations

    delegate :id, to: :current_department, prefix: true
  end

  def set_current_structure_type
    current_structure_type
  end

  def set_current_organisation_id
    @current_organisation_id = params[:organisation_id].to_i if @current_structure_type == "organisation"
  end

  def set_current_department_id
    @current_department_id = params[:department_id].to_i if @current_structure_type == "department"
  end

  def set_current_structure
    current_structure
  end

  def set_current_department
    current_department
  end

  def set_current_organisation
    current_organisation
  end

  def set_current_agent_department_organisations
    current_agent_department_organisations
  end

  def current_agent_department_organisations
    return unless current_agent && @current_department

    @current_agent_department_organisations ||= current_department.organisations & current_agent.organisations
  end

  def department_level?
    @current_structure_type == "department"
  end

  def current_structure_type
    @current_structure_type ||=
      if params[:department_id].nil? && params[:organisation_id].nil?
        nil
      elsif params[:organisation_id].present?
        "organisation"
      else
        "department"
      end
  end

  def current_structure
    return unless @current_department_id || @current_organisation_id

    @current_structure ||=
      if department_level?
        policy_scope(Department).find(@current_department_id)
      else
        policy_scope(Organisation).find(@current_organisation_id)
      end
  end

  def current_department
    return unless current_structure

    @current_department ||=
      department_level? ? current_structure : current_structure.department
  end

  def current_organisation
    return if department_level?

    @current_organisation ||= current_structure
  end

  def current_department_name
    @current_department&.name
  end

  def current_structure_name
    @current_structure&.name
  end

  def current_organisation_ids
    @current_organisation_ids ||=
      department_level? ? current_department.organisation_ids : [@current_organisation_id]
  end

  def current_organisation_id
    @current_organisation_id
  end

  def current_department_id
    @current_department_id
  end

  def current_organisations_filter
    if department_level?
      { organisations: { department_id: @current_department_id } }
    else
      { organisations: [@current_organisation_id] }
    end
  end

  def current_organisation_filter
    if department_level?
      { organisation: { department_id: @current_department_id } }
    else
      { organisation_id: @current_organisation_id }
    end
  end
end
