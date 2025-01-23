module Users
  class OrientationsController < ApplicationController
    before_action :set_user, :set_organisations, :set_agents, only: [:new, :edit, :create, :update]
    before_action :set_orientations, only: [:create, :update]
    before_action :set_orientation, only: [:edit, :update, :destroy]
    before_action :set_agent_ids_by_organisation_id, :set_orientation_types, only: [:new, :edit]

    def new
      @orientation = Orientation.new(user: @user)
    end

    def edit; end

    def create
      @orientation = Orientation.new(user: @user, **orientation_params)
      save_orientation_and_redirect
    end

    def update
      @orientation.assign_attributes(**orientation_params)
      save_orientation_and_redirect
    end

    def destroy
      @user = @orientation.user
      if @orientation.destroy
        redirect_to structure_user_parcours_path(@user.id)
      else
        turbo_stream_prepend_flash_messages(
          error: "Impossible de supprimer l'orientation: #{@orientation.errors.full_messages}"
        )
      end
    end

    private

    def orientation_params
      params.require(:orientation).permit(:starts_at, :ends_at, :orientation_type_id,
                                          :organisation_id, :agent_id)
    end

    def set_user
      @user = policy_scope(User).find(params[:user_id])
    end

    def set_organisations
      @organisations = current_department
                       .organisations
                       .active
                       .where(organisation_type: Organisation::ORGANISATION_TYPES_WITH_PARCOURS_ACCESS)
                       .includes(:agents)
    end

    def set_agents
      @agents = current_department.agents.with_last_name.distinct
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

    def set_orientations
      @orientations = policy_scope(@user.orientations)
                      .where(organisation: { department_id: current_department_id })
                      .includes(:agent, :organisation, :orientation_type).order(starts_at: :asc)
    end

    def set_orientation_types
      @orientation_types = OrientationType.for_department(@current_department)
    end

    def reloaded_user_orientations
      @user.reload.orientations.includes(:organisation, :agent)
    end

    def save_orientation_and_redirect
      @should_notify_organisation = new_organisation?
      if save_orientation.success?
        render :create
      elsif save_orientation.shrinkeable_orientation.present?
        turbo_stream_confirm_update_anterior_ends_at_modal
      else
        turbo_stream_replace_error_list_with(save_orientation.errors)
      end
    end

    def save_orientation
      @save_orientation ||= Orientations::Save.call(
        orientation: @orientation,
        update_anterior_ends_at: params[:orientation][:update_anterior_ends_at]
      )
    end

    def turbo_stream_confirm_update_anterior_ends_at_modal
      turbo_stream_display_modal(
        partial: "users/orientations/confirm_update_anterior_ends_at",
        locals: {
          shrinkeable_orientation: save_orientation.shrinkeable_orientation,
          orientation: @orientation,
          orientation_params:,
          user: @user
        }
      )
    end

    def new_organisation?
      @user.organisations.exclude?(@orientation.organisation)
    end
  end
end
