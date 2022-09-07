# Where the bRSA lands after his teleprocedure online

class TeleprocedureLandingsController < ApplicationController
  skip_before_action :authenticate_agent!

  def show
    @department = Department.find_by!(number: params[:department_number])
    @department_logo_format = %w[svg png jpg].find do |format|
      Webpacker.manifest.lookup("media/images/logos/#{@department.name.parameterize}.#{format}")
    end
  end
end
