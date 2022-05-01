class StatsController < ApplicationController
  skip_before_action :authenticate_agent!, only: [:index]

  include StatsConcern

  def index
    @deployment_map = params[:deployment_map] == "true"
    if params[:department_number].blank?
      collect_datas_for_stats
    else
      filter_stats_by_department
    end
    set_stats_datas
  end
end
