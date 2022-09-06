# Where the bRSA lands after his teleprocedure online

class TeleprocedureLandingsController < ApplicationController
  skip_before_action :authenticate_agent!

  def show
    @department = Department.find_by!(number: params[:department_number])
    @department_logo_format =
      if Webpacker.manifest.lookup("media/images/logos/#{@department.name.parameterize}.svg")
        "svg"
      elsif Webpacker.manifest.lookup("media/images/logos/#{@department.name.parameterize}.png")
        "png"
      elsif Webpacker.manifest.lookup("media/images/logos/#{@department.name.parameterize}.jpg")
        "jpg"
      end
  end
end
