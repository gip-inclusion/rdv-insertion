class ConfigurationsPositionsController < ApplicationController
  def update
    params.require(:configuration_ids_and_positions).each do |configuration_id_and_position|
      # We update all configurations with similar motif_category because updating only the given one would
      # break department level ordering (since we have multiple configurations with the same motif_category)
      configurations
        .where(motif_category: configurations.find(configuration_id_and_position[:id]).motif_category)
        .update_all(column_to_update => configuration_id_and_position[:position].to_i)
    end

    head :ok
  end

  private

  def column_to_update
    department_level? ? :department_position : :position
  end

  def configurations
    @configurations ||= department_or_organisation.configurations.includes([:motif_category]).order(position: :asc)
  end

  def department_or_organisation
    department_level? ? department : organisation
  end

  def department
    @department ||= policy_scope(Department).find(params[:department_id])
  end

  def organisation
    @organisation ||= policy_scope(Organisation).find(params[:organisation_id])
  end
end
