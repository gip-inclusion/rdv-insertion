module Website
  class StatsController < BaseController
    rate_limit_with_json_response limit: ENV.fetch("RATE_LIMIT_STATS", ENV["RATE_LIMIT_DEFAULT"]).to_i,
                                  period: 1.minute

    skip_before_action :authenticate_agent!, only: [:index, :show, :deployment_map]
    before_action :set_organisation, :set_department, :set_stat, only: [:show]
    before_action :set_departments, only: [:index, :show]
    # Chartkick needs a full page reload to work with our CSP.
    before_action :force_full_page_reload, only: [:index, :show]

    def index
      @department_count = @departments.count
      @stat = Stat.find_by(statable_type: "Department", statable_id: nil)
    end

    def show; end

    def deployment_map; end

    private

    def set_departments
      @departments = Department.displayed_in_stats.order(:number)
    end

    def set_organisation
      @organisation = Organisation.find(params[:organisation_id_for_stats]) if params[:organisation_id_for_stats]
    end

    def set_department
      @department = @organisation&.department || Department.find(params[:department_id_for_stats])
    end

    def structure = @organisation || @department

    def set_stat
      @stat = structure.stat
    end
  end
end
