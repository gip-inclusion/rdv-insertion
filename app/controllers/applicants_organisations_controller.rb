class ApplicantsOrganisationsController < ApplicationController
  before_action :set_applicant, :set_department, :set_organisations, only: [:new, :create]
  before_action :set_organisation, only: [:create]

  def new; end

  def create
    if save_applicant.success?
      respond_to do |format|
        format.turbo_stream
      end
    else
      flash[:error] = save_applicant.errors&.join(", ")
      redirect_to department_applicant_path(@department, @applicant)
    end
  end

  private

  def applicants_organisations
    (@applicant.organisations.to_a + [@organisation]).uniq
  end

  def applicants_organisation_params
    params.require(:applicants_organisation).permit(:organisation_id)
  end

  def set_applicant
    @applicant = policy_scope(Applicant).find(params[:applicant_id])
    authorize @applicant
  end

  def set_department
    @department = policy_scope(Department).find(params[:department_id])
  end

  def set_organisation
    @organisation = Organisation.find(applicants_organisation_params[:organisation_id])
  end

  def set_organisations
    @organisations = @department.organisations - @applicant.organisations
  end

  def save_applicant
    @save_applicant ||= Applicants::Save.call(
      applicant: @applicant,
      organisation: @organisation,
      rdv_solidarites_session: rdv_solidarites_session
    )
  end
end
