module Organisations
  module CategoryConfigurations
    class FileConfigurationsController < BaseController
      before_action :set_department, :set_file_configurations, only: [:edit]

      def show; end

      def edit
        set_file_selection_modal_context
      end

      # Uses params[:file_configuration_id] directly (not strong params) because:
      # - The shared _select_modal uses radio_button_tag which sends params at root level
      # - No mass assignment risk: we explicitly set a single attribute
      def update
        if params[:file_configuration_id].blank?
          return turbo_stream_replace_error_list_with(["Veuillez sélectionner un modèle de fichier"])
        end

        @category_configuration.file_configuration_id = params[:file_configuration_id]
        if @category_configuration.save
          render :update
        else
          turbo_stream_replace_error_list_with(@category_configuration.errors.full_messages)
        end
      end

      private

      def set_file_configurations
        @file_configurations =
          FileConfiguration
          .preload(:organisations, category_configurations: [:motif_category, :organisation])
          .where(id: department_scope_file_configuration_ids + agent_scope_file_configuration_ids)
          .distinct.order(:created_at)
      end

      def department_scope_file_configuration_ids
        policy_scope(FileConfiguration)
          .joins(category_configurations: :organisation)
          .where(organisations: { department_id: @organisation.department_id }).pluck(:id)
      end

      def agent_scope_file_configuration_ids
        policy_scope(FileConfiguration).where(created_by_agent: current_agent)
                                       .where.missing(:category_configurations)
                                       .pluck(:id)
      end

      def set_file_selection_modal_context
        @return_to_selection_path = edit_organisation_category_configuration_file_configurations_path(
          @organisation, @category_configuration
        )
        @current_file_configuration = @category_configuration.file_configuration
      end
    end
  end
end
