class ArchivingDatesFilteringsController < ApplicationController
  include BackToListConcern

  before_action :set_organisation, :set_department, :set_back_to_list_url, only: [:new]

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
