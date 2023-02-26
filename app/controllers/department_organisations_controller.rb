class DepartmentOrganisationsController < ApplicationController
  before_action :set_department, only: [:index]

  def index
    @organisations = policy_scope(Organisation).where(department: @department)
                                               .where(id: current_agent.admin_organisations)
  end

  private

  def set_department
    @department = Department.find(params[:department_id])
  end
end
