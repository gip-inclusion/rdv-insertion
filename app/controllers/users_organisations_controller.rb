class UsersOrganisationsController < ApplicationController
  before_action :set_user, :set_department, :set_organisations,
                only: [:index, :create, :destroy]
  before_action :assign_motif_category, :set_organisation_to_add, only: [:create]
  before_action :set_organisation_to_remove, only: [:destroy]

  def index; end

  def create
    if save_user.success?
      flash.now[:success] = "L'organisation a bien été ajoutée"
      # in this case we need to refresh the page in case there are new rdv contexts
      redirect_to_department_user_path if department_level?
    else
      flash.now[:error] = "Une erreur s'est produite lors de l'ajout de l'organisation: #{save_user.errors}"
    end
  end

  def destroy
    if remove_user_from_org.success?
      flash.now[:success] = "L'organisation a bien été retirée"

      redirect_to_users_list if user_deleted_or_removed_from_current_org?
    else
      flash.now[:error] = "Une erreur s'est produite lors du retrait de " \
                          "l'organisation: #{remove_user_from_org.errors}"
    end
  end

  private

  def users_organisation_params
    params.require(:users_organisation).permit(:organisation_id, :user_id, :motif_category_id)
  end

  def user_id
    params[:user_id] || users_organisation_params[:user_id]
  end

  def set_user
    @user = policy_scope(User).find(user_id)
  end

  def set_department
    @department = policy_scope(Department).find(current_department_id)
  end

  def set_organisation_to_add
    @organisation_to_add = @department.organisations.find(users_organisation_params[:organisation_id])
  end

  def set_organisation_to_remove
    @organisation_to_remove = @department.organisations.find(users_organisation_params[:organisation_id])
  end

  def set_organisations
    @organisations = @department.organisations.includes(:motif_categories)
  end

  def set_user_organisations
    @user_organisations = @user.reload.organisations
  end

  def redirect_to_users_list
    redirect_to session[:back_to_users_list_url] || structure_users_path
  end

  def redirect_to_department_user_path
    redirect_to(
      department_user_path(@department, @user),
      flash: { success: "L'organisation a bien été ajoutée" }
    )
  end

  def user_deleted_or_removed_from_current_org?
    @user.deleted? || @organisation_to_remove.id.to_s == Current.organisation_id
  end

  def assign_motif_category
    return if users_organisation_params[:motif_category_id].blank?

    @user.assign_motif_category(users_organisation_params[:motif_category_id])
  end

  def save_user
    @save_user ||= Users::Save.call(
      user: @user,
      organisation: @organisation_to_add,
      rdv_solidarites_session: rdv_solidarites_session
    )
  end

  def remove_user_from_org
    @remove_user_from_org ||= Users::RemoveFromOrganisation.call(
      user: @user,
      organisation: @organisation_to_remove,
      rdv_solidarites_session: rdv_solidarites_session
    )
  end
end
