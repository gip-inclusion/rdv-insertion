class ConfigurationsController < ApplicationController
  include BackToListConcern

  before_action :set_organisation, :set_department, :authorize_organisation_configuration,
                :set_messages_configuration, :set_category_configurations, :set_available_tags,
                :set_user_count_by_tag_id, :set_agent_roles,
                only: [:show]

  def show; end

  private

  def set_organisation
    @organisation = Organisation.find(params[:organisation_id])
  end

  def set_department
    @department = @organisation.department
  end

  def authorize_organisation_configuration
    authorize @organisation, :configure?
  end

  def set_messages_configuration
    @messages_configuration = @organisation.messages_configuration
  end

  def set_category_configurations
    @category_configurations = @organisation.category_configurations.includes([:motif_category])
  end

  def set_available_tags
    @available_tags = @department.tags.distinct
  end

  def set_user_count_by_tag_id
    @user_count_by_tag_id = User.joins(:tags, :organisations)
                                .where(tags: { id: @available_tags.pluck(:id) })
                                .where(organisations: { id: @organisation.id })
                                .distinct
                                .group(:tag_id)
                                .count
  end

  def set_agent_roles
    @agent_roles = @organisation.agent_roles
  end
end
