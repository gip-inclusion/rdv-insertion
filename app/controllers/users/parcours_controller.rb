module Users
  class ParcoursController < ApplicationController
    before_action :set_user, :set_department, :set_organisation, :set_user_tags, :set_back_to_users_list_url,
                  :set_current_organisations, :set_user_archives, :set_user_archive_status, only: [:show]

    include BackToListConcern
    include Users::Taggable
    include Users::Archivable

    def show
      @orientations = policy_scope(@user.orientations)
                      .where(organisation: { department_id: current_department_id })
                      .includes(:agent, :organisation, :orientation_type).order(starts_at: :asc)
      @diagnostics = @user.diagnostics.where(department: @department).order(document_date: :desc, id: :desc)
      @contracts = @user.contracts.where(department: @department).order(document_date: :desc, id: :desc)
    end

    private

    def set_department
      @department = current_department
      authorize(@department, :parcours?)
    end

    def set_organisation
      return if department_level?

      @organisation = current_organisation
      authorize(@organisation, :parcours?)
    end

    def set_user
      @user = policy_scope(User).preload(:archives).find(params[:user_id])
    end

    def set_user_archives
      @user_archives = @user.archives
    end

    def set_user_archive_status
      @user_archived_for_current_organisations =
        @user.archives.where(organisation: @current_organisations).count == @current_organisations.count
    end

    def set_current_organisations
      @current_organisations = department_level? ? current_agent_department_organisations : [@organisation]
    end
  end
end
