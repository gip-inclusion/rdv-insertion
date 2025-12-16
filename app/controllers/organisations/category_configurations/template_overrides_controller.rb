class Organisations::CategoryConfigurations::TemplateOverridesController < ApplicationController
  before_action :set_organisation, :set_category_configuration

  def show; end

  def edit; end

  def update
    if @category_configuration.update(template_override_params)
      redirect_to organisation_category_configuration_template_overrides_path(@organisation, @category_configuration)
    else
      turbo_stream_replace_error_list_with(@category_configuration.errors.full_messages)
    end
  end

  private

  def set_organisation
    @organisation = Organisation.find(params[:organisation_id])
    authorize @organisation, :configure?
  end

  def set_category_configuration
    @category_configuration = @organisation.category_configurations.find(params[:category_configuration_id])
  end

  def template_override_params
    params.expect(
      category_configuration: [
        :template_rdv_title_override,
        :template_rdv_title_by_phone_override,
        :template_user_designation_override,
        :template_rdv_purpose_override
      ]
    )
  end
end
