class DepartmentsController < ApplicationController
  def index
    @departments = policy_scope(Department)
    redirect_to department_applicants_path(@departments.first) if @departments.size == 1
  end
end
