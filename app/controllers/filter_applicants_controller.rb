class FilterApplicantsController < ApplicationController
  before_action :set_organisation, :set_department, only: [:new]

  def new; end

  private

  def set_organisation
    return if department_level?

    @organisation = \
      policy_scope(Organisation).includes(:applicants, :configurations).find(params[:organisation_id])
  end

  def set_department
    @department = \
      if department_level?
        policy_scope(Department).includes(:organisations, :applicants).find(params[:department_id])
      else
        @organisation.department
      end
  end
end
