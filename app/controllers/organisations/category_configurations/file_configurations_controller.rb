module Organisations
  module CategoryConfigurations
    class FileConfigurationsController < BaseController
      include Concerns::FileConfigurationsLoadable

      before_action :set_file_configurations, only: [:edit]

      def show; end

      def edit
        set_file_selection_modal_context
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

      def set_file_selection_modal_context
        @return_to_selection_path = edit_organisation_category_configuration_file_configurations_path(
          @organisation, @category_configuration
        )
        @current_file_configuration = @category_configuration.file_configuration
      end
    end
  end
end
