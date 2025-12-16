module Organisations
  module CategoryConfigurations
    class FileConfigurationSelectionsController < BaseController
      include Concerns::FileConfigurationsLoadable

      # Skip set_category_configuration because in NEW context there's no existing category_configuration yet
      skip_before_action :set_category_configuration
      before_action :set_file_configurations

      def new
        set_file_selection_modal_context
      end

      # Uses params[:file_configuration_id] directly (not strong params) because:
      # The shared _select_modal uses radio_button_tag which sends params at root level
      def create
        if params[:file_configuration_id].blank?
          return turbo_stream_replace_error_list_with(["Veuillez sélectionner un modèle de fichier"])
        end

        @selected_file_configuration = FileConfiguration.find(params[:file_configuration_id])
      end

      private

      def set_file_selection_modal_context
        selected_id = params[:selected_file_configuration_id]
        @return_to_selection_path = new_organisation_file_configuration_selection_path(
          @organisation, selected_file_configuration_id: selected_id
        )
        @current_file_configuration = selected_id ? FileConfiguration.find(selected_id) : nil
      end
    end
  end
end
