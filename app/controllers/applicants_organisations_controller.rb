class ApplicantsOrganisationsController < ApplicationController
  before_action :set_applicant, :set_department, :set_organisations, :set_current_organisation,
                only: [:index, :create, :destroy]
  before_action :assign_motif_category, :set_organisation_to_add, only: [:create]
  before_action :set_organisation_to_remove, only: [:destroy]

  def index; end

  def create
    if save_applicant.success?
      flash.now[:success] = "L'organisation a bien été ajoutée"
      # in this case we need to refresh the page in case there are new rdv contexts
      redirect_to_department_applicant_path unless @current_organisation
    else
      flash.now[:error] = "Une erreur s'est produite lors de l'ajout de l'organisation: #{save_applicant.errors}"
    end
  end

  def destroy
    if remove_applicant_from_org.success?
      flash.now[:success] = "L'organisation a bien été retirée"
    else
      flash.now[:error] = "Une erreur s'est produite lors du retrait de " \
                          "l'organisation: #{remove_applicant_from_org.errors}"
    end
    redirect_to_list if applicant_deleted_or_removed_from_current_org?
  end

  private

  def applicants_organisation_params
    params.require(:applicants_organisation).permit(:organisation_id, :applicant_id, :motif_category_id)
  end

  def applicant_id
    params[:applicant_id] || applicants_organisation_params[:applicant_id]
  end

  def set_applicant
    @applicant = policy_scope(Applicant).find(applicant_id)
  end

  def set_department
    @department = policy_scope(Department).find(params[:department_id])
  end

  def set_organisation_to_add
    @organisation_to_add = @department.organisations.find(applicants_organisation_params[:organisation_id])
  end

  def set_organisation_to_remove
    @organisation_to_remove = @department.organisations.find(applicants_organisation_params[:organisation_id])
  end

  # this lets us know from which organisation we are seeing the applicant if we are at the org level
  def set_current_organisation
    return unless params[:current_organisation_id]

    @current_organisation = policy_scope(Organisation).find(params[:current_organisation_id])
  end

  def set_organisations
    @organisations = @department.organisations.includes(:motif_categories)
  end

  def set_applicant_organisations
    @applicant_organisations = @applicant.reload.organisations
  end

  def redirect_to_list
    redirect_to session[:back_to_list_url] || department_applicants_path(@department)
  end

  def redirect_to_department_applicant_path
    redirect_to(
      department_applicant_path(@department, @applicant),
      flash: { success: "L'organisation a bien été ajoutée" }
    )
  end

  def applicant_deleted_or_removed_from_current_org?
    @applicant.deleted? || @organisation_to_remove == @current_organisation
  end

  def assign_motif_category
    return if applicants_organisation_params[:motif_category_id].blank?

    @applicant.assign_motif_category(applicants_organisation_params[:motif_category_id])
  end

  def save_applicant
    @save_applicant ||= Applicants::Save.call(
      applicant: @applicant,
      organisation: @organisation_to_add,
      rdv_solidarites_session: rdv_solidarites_session
    )
  end

  def remove_applicant_from_org
    @remove_applicant_from_org ||= Applicants::RemoveFromOrganisation.call(
      applicant: @applicant,
      organisation: @organisation_to_remove,
      rdv_solidarites_session: rdv_solidarites_session
    )
  end
end
