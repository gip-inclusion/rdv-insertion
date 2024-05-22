module Users
  class OrientationsController < ApplicationController
    before_action :set_user, :set_organisations, :set_agents, only: [:new, :edit, :create, :update]
    before_action :set_orientation, only: [:edit, :update, :destroy]
    before_action :set_agent_ids_by_organisation_id, only: [:new, :edit]

    def new
      @orientation = Orientation.new(user: @user)
    end

    def edit; end

    def create
      @orientation = Orientation.new(user: @user, **orientation_params)
      if save_orientation.success?
        redirect_to department_user_parcours_path(user_id: @user.id, department_id: current_department_id)
      else
        turbo_stream_replace_error_list_with(save_orientation.errors)
      end
    end

    def update
      @orientation.assign_attributes(**orientation_params)
      if save_orientation.success?
        redirect_to department_user_parcours_path(user_id: @user.id, department_id: current_department_id)
      else
        turbo_stream_replace_error_list_with(save_orientation.errors)
      end
    end

    def destroy
      if @orientation.destroy
        redirect_to department_user_parcours_path(user_id: @user.id, department_id: current_department_id)
      else
        turbo_stream_prepend_flash_message(
          error: "Impossible de supprimer l'orientation: #{@orientation.errors.full_messages}"
        )
      end
    end

    private

    def orientation_params
      params.require(:orientation).permit(:starts_at, :ends_at, :orientation_type, :organisation_id, :agent_id)
    end

    def set_user
      @user = policy_scope(User).find(params[:user_id])
    end

    def set_organisations
      @organisations = current_department.organisations.includes(:agents)
    end

    def set_agents
      @agents = current_department.agents.distinct
    end

    def set_agent_ids_by_organisation_id
      @agent_ids_by_organisation_id = @organisations.to_h do |organisation|
        [organisation.id, organisation.agent_ids]
      end
    end

    def set_orientation
      @orientation = Orientation.find(params[:id])
      authorize @orientation
    end

    def reloaded_user_orientations
      @user.reload.orientations.includes(:organisation, :agent)
    end

    def save_orientation
      @save_orientation ||= Orientations::Save.call(orientation: @orientation)
    end
  end
end
