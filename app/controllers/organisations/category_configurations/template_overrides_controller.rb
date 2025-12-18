module Organisations
  module CategoryConfigurations
    class TemplateOverridesController < BaseController
      def show; end

      def edit; end

      def update
        if @category_configuration.update(template_override_params)
          redirect_to organisation_category_configuration_template_override_path(@organisation, @category_configuration)
        else
          turbo_stream_replace_error_list_with(@category_configuration.errors.full_messages)
        end
      end

      private

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
  end
end
