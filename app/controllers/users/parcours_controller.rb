module Users
  class ParcoursController < ApplicationController
    before_action :set_user, :set_user_tags, :set_back_to_users_list_url,
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
      authorize(current_structure, :parcours?)
    end

    def set_user
      @user = policy_scope(User).preload(:archives).find(params[:user_id])
    end
  end
end
