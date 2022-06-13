class StatsController < ApplicationController
  skip_before_action :authenticate_agent!, only: [:index, :show, :deployment_map]

  def index
    @department_count = Department.count
    @stat = Stat.where(department_number: nil).last
  end

  def show
    @stat = Stat.where(department_id: params[:id]).last
    @display_all_stats = Department.find(params[:id]).configurations.none?(&:notify_applicant?)
  end

  def deployment_map; end
end
