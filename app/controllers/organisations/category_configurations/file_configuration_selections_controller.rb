module Organisations
  module CategoryConfigurations
    class FileConfigurationSelectionsController < BaseController
      include Concerns::FileConfigurationsLoadable

      # Skip set_category_configuration for new/create (no category_configuration exists yet)
      skip_before_action :set_category_configuration, only: [:new, :create]
      before_action :set_file_configurations, only: [:new, :edit]

      def new
        set_new_context
      end

      # Uses params[:file_configuration_id] directly (not strong params) because:
      # The shared _select_modal uses radio_button_tag which sends params at root level
      def create
        if params[:file_configuration_id].blank?
          return turbo_stream_replace_error_list_with(["Veuillez sélectionner un modèle de fichier"])
        end

        @selected_file_configuration = FileConfiguration.find(params[:file_configuration_id])
      end

      def edit
        set_edit_context
      end

      # Uses params[:file_configuration_id] directly (not strong params) because:
      # The shared _select_modal uses radio_button_tag which sends params at root level
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

      def set_new_context
        selected_id = params[:selected_file_configuration_id]
        @return_to_selection_path = new_organisation_file_configuration_selection_path(
          @organisation, selected_file_configuration_id: selected_id
        )
        @current_file_configuration = selected_id ? FileConfiguration.find(selected_id) : nil
      end

      def set_edit_context
        @return_to_selection_path = edit_organisation_category_configuration_file_configuration_selection_path(
          @organisation, @category_configuration
        )
        @current_file_configuration = @category_configuration.file_configuration
      end
    end
  end
end
