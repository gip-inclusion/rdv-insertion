class UploadsController < ApplicationController
  before_action :set_department, only: [:new]

  def new
    authorize @department, :list_applicants?
    @configuration = @department.configuration
  end

  private

  def set_department
    @department = Department.find(params[:department_id])
  end
end
