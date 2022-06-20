class StatsController < ApplicationController
  skip_before_action :authenticate_agent!, only: [:index, :show, :deployment_map]
  before_action :set_department, only: [:show]

  def index
    @department_count = Department.count
    @stat = Stat.find_by(department_number: "all")
  end

  def show
    @stat = Stat.find_by(department_number: @department.number)
    @display_all_stats = @department.configurations.none?(&:notify_applicant?)
  end

  def deployment_map; end

  private

  def set_department
    @department = Department.find(params[:id])
  end
end
