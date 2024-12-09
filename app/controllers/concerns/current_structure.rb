module CurrentStructure
  extend ActiveSupport::Concern

  included do
    helper_method :current_structure_type, :department_level?,
                  :current_structure, :current_structure_name, :current_structure_id,
                  :current_department, :current_department_name, :current_department_id,
                  :current_organisations, :current_organisation, :current_organisation_id,
                  :current_agent_department_organisations, :current_agent_role,
                  :current_structure_type_in_params

    delegate :name, to: :current_structure, prefix: true
    delegate :name, to: :current_department, prefix: true

    before_action :set_current_structure_in_session
  end

  def set_current_structure_in_session
    return if current_structure_type_in_params.blank?

    session[:current_structure_type] = current_structure_type_in_params
    session[:department_id] = params[:department_id]
    session[:organisation_id] = params[:organisation_id]
  end

  def current_structure_type_in_params
    @current_structure_type_in_params ||=
      if params[:department_id].nil? && params[:organisation_id].nil?
        nil
      elsif params[:organisation_id].present?
        "organisation"
      else
        "department"
      end
  end

  def current_structure_type
    @current_structure_type ||= session[:current_structure_type]
  end

  def department_level?
    current_structure_type == "department"
  end

  def current_organisation_id
    @current_organisation_id ||= session[:organisation_id].to_i if current_structure_type == "organisation"
  end

  def current_department_id
    @current_department_id ||= department_level? ? session[:department_id].to_i : current_department&.id
  end

  def current_structure_id = current_organisation_id || current_department_id

  def current_structure
    return unless session[:department_id] || session[:organisation_id]

    @current_structure ||=
      department_level? ? Department.find(current_department_id) : Organisation.find(current_organisation_id)

    authorize @current_structure, :access?
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

  def current_agent_department_organisations
    return unless current_agent && current_department

    @current_agent_department_organisations ||= policy_scope(current_department.organisations)
  end

  def current_agent_role
    return if current_agent.nil? || current_organisation.nil?

    current_organisation.agent_roles.find_by(agent_id: current_agent.id)
  end

  def current_organisations
    @current_organisations ||= department_level? ? current_agent_department_organisations : [current_organisation]
  end

  def current_organisation_ids
    current_organisations.map(&:id)
  end

  def current_organisations_filter
    if department_level?
      { organisations: { department_id: current_department_id } }
    else
      { organisations: [current_organisation_id] }
    end
  end

  def current_organisation_filter
    if department_level?
      { organisation: { department_id: current_department_id } }
    else
      { organisation_id: current_organisation_id }
    end
  end
end
