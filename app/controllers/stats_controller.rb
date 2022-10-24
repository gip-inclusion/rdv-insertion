class StatsController < ApplicationController
  skip_before_action :authenticate_agent!, only: [:index, :show, :deployment_map]
  before_action :set_department, only: [:show]

  def index
    @department_count = Department.displayed_in_stats.count
    @stat = Stat.find_by(department_number: "all")
  end

  def show
    @stat = Stat.find_by(department_number: @department.number)
    # we don't display all stats for departments who don't invite applicants
    @display_all_stats = @department.configurations.none? { |configuration| configuration.invitation_formats.blank? }
  end

  def deployment_map; end

  private

  def set_department
    @department = Department.find(params[:id])
  end
end
