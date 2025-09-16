module Users
  class ParcoursController < ApplicationController
    include Users::EnsurePresenceInStructure

    before_action :set_user, :ensure_user_presence_in_structure, :set_user_tags, :set_back_to_users_list_url,
                  :ensure_has_access_to_parcours, only: [:show]

    include BackToListConcern
    include Users::Taggable

    def show
      @orientations = policy_scope(@user.orientations)
                      .where(organisation: { department_id: current_department_id })
                      .includes(:agent, :organisation, :orientation_type).order(starts_at: :asc)
      @diagnostics = @user.diagnostics.where(department_id: current_department_id).order(document_date: :desc,
                                                                                         id: :desc)
      @contracts = @user.contracts.where(department_id: current_department_id).order(document_date: :desc, id: :desc)
    end

    private

    def ensure_has_access_to_parcours
      return authorize(current_structure, :parcours?) if current_structure.is_a?(Organisation)
      return if DepartmentPolicy.new(pundit_user, current_structure).parcours?(user: @user)

      flash[:error] = "Votre compte ne vous permet pas d'effectuer cette action"
      redirect_to structure_users_path
    end

    def set_user
      @user = policy_scope(User).where(current_organisations_filter).preload(:archives).find_by(id: params[:user_id])
    end
  end
end
