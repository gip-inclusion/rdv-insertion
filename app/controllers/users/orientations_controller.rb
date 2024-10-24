module Users
  class OrientationsController < ApplicationController
    before_action :set_user, :set_organisations, :set_agents, only: [:new, :edit, :create, :update]
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
        turbo_stream_prepend_flash_message(
          error: "Impossible de supprimer l'orientation: #{@orientation.errors.full_messages}"
        )
      end
    end

    private

    def orientation_params
      @orientation_params ||= params.require(:orientation).permit(:starts_at, :ends_at, :orientation_type_id,
                                                                  :organisation_id, :agent_id)
    end

    def set_user
      @user = policy_scope(User).find(params[:user_id])
    end

    def set_organisations
      @organisations = current_department
                       .organisations
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

    def set_orientation_types
      @orientation_types = OrientationType.for_department(@current_department)
    end

    def reloaded_user_orientations
      @user.reload.orientations.includes(:organisation, :agent)
    end

    def save_orientation_and_redirect
      if save_orientation.success?
        turbo_stream_redirect structure_user_parcours_path(@user.id)
      elsif requires_overlap_override_confirmation?
        turbo_stream_confirm_override_overlap_modal
      else
        turbo_stream_replace_error_list_with(save_orientation.errors)
      end
    end

    def save_orientation
      @save_orientation ||= Orientations::Save.call(
        orientation: @orientation,
        should_override_overlap: params[:override_overlap]
      )
    end

    def requires_overlap_override_confirmation?
      save_orientation.errors.one? &&
        save_orientation.errors.first.is_a?(Hash) &&
        save_orientation.errors.first[:overrideable_overlap]
    end

    def turbo_stream_confirm_override_overlap_modal
      render turbo_stream: turbo_stream.replace(
        "remote_modal",
        partial: "users/orientations/confirm_override_overlap",
        locals: { overlapping_orientation: save_orientation.errors.first[:overlapping_orientation] }
      )
    end
  end
end
