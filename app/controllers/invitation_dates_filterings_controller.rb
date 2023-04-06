class InvitationDatesFilteringsController < ApplicationController
  before_action :set_organisation, :set_department, only: [:new]

  def new; end

  private

  def set_organisation
    return if department_level?

    @organisation =
      policy_scope(Organisation).find(params[:organisation_id])
  end

  def set_department
    @department =
      if department_level?
        policy_scope(Department).find(params[:department_id])
      else
        @organisation.department
      end
  end
end
