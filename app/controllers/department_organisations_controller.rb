class DepartmentOrganisationsController < ApplicationController
  before_action :set_department, only: [:index]

  def index
    @organisations = policy_scope(Organisation).where(department: @department)
  end

  private

  def set_department
    @department = Department.find(params[:department_id])
  end
end
