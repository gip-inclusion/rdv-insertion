module Organisations
  module CategoryConfigurations
    class FileConfigurationSelectionsController < BaseController
      # Skip set_category_configuration for new/create (no category_configuration exists yet)
      skip_before_action :set_category_configuration, only: [:new, :create]
      before_action :set_file_configurations, only: [:new, :edit]

      def new; end

      def edit
        @current_file_configuration = @category_configuration.file_configuration
      end

      def create
        @selected_file_configuration = FileConfiguration.find(params[:file_configuration_id])
        authorize @selected_file_configuration, :show?
        render :create
      end

      def update
        file_configuration = FileConfiguration.find(params[:file_configuration_id])
        authorize file_configuration, :show?

        if @category_configuration.update(file_configuration:)
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
    end
  end
end
