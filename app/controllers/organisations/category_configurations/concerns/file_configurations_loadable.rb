# Shared logic for controllers that need to load file configurations
# scoped to the current organisation's department.
module Organisations
  module CategoryConfigurations
    module Concerns
      module FileConfigurationsLoadable
        extend ActiveSupport::Concern

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
end
