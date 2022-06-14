class StatsController < ApplicationController
  skip_before_action :authenticate_agent!, only: [:index, :show, :deployment_map]
  before_action :set_department, only: [:show]

  def index
    @applicants = Applicant.all
    @rdvs = Rdv.all
    @department_count = Department.count
    @stats = Stat.new(department_ids: Department.pluck(:id))
  end

  def show
    @applicants = @department.applicants
    @rdvs = @department.rdvs
    @display_all_stats = @department.configurations.none?(&:notify_applicant?)
    @stats = Stat.new(department_ids: [@department.id])
  end

  def deployment_map; end

  private

  def set_department
    @department = Department.find(params[:id])
  end
end
