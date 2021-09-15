class DepartmentsController < ApplicationController
  def index
    @departments = Department.all
  end
end
