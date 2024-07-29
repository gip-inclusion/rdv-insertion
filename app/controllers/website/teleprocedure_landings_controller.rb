# Where the bRSA lands after his teleprocedure online
module Website
  class TeleprocedureLandingsController < BaseController
    skip_before_action :authenticate_agent!

    def show
      @department = Department.find_by!(number: params[:department_number])
    end
  end
end
