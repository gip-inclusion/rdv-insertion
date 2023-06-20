module SetAllConfigurationsConcern
  include ActiveSupport::Concern

  private

  def set_all_configurations
    @all_configurations =
      if department_level?
        (policy_scope(::Configuration).includes(:motif_category) & @department.configurations).uniq(&:motif_category_id)
      else
        @organisation.configurations.includes(:motif_category)
      end
    @all_configurations = @all_configurations.sort_by(&:motif_category_position)
  end
end
