class ApplicantsOrganisationsController < ApplicationController
  before_action :set_applicant, :set_department, :set_organisations, :set_assign_rdv_context, only: [:new, :create]
  before_action :set_organisation, only: [:create]

  def new; end

  def create
    @applicant.assign_attributes(organisations: applicants_organisations)

    if save_applicant.success?
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to department_applicant_path(@department, @applicant) }
      end
    else
      flash.now[:error] = save_applicant.errors&.join(',')
      render :new, status: :unprocessable_entity
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
    @save_applicant ||= SaveApplicant.call(
      applicant: @applicant,
      organisation: @organisation,
      rdv_solidarites_session: rdv_solidarites_session
    )
  end

  def set_assign_rdv_context
    @assign_rdv_context = params[:assign_rdv_context]
  end

  def after_succes_redirect
    if @assign_rdv_context
      redirect_to(
        new_applicant_rdv_context_path(@applicant, organisation_id: @organisation.id)
      )
    else
      redirect_to department_applicant_path(@applicant.department, @applicant)
    end
  end
end
