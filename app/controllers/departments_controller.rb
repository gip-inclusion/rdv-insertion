class DepartmentsController < ApplicationController
  skip_before_action :authenticate_agent!, only: [:index]

  def index
    @departments = Department.all
  end
end
