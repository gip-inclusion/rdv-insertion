module Configurations
  class MessagesContentsController < ApplicationController
    before_action :set_configuration, :set_template

    def show; end

    def edit; end

    def update
      if @configuration.update(overriden_attributes)
        render :show
      else
        render :edit
      end
    end

    private

    def set_configuration
      @configuration = ::Configuration.find(params[:configuration_id])
      authorize @configuration
    end

    def set_template
      @template = @configuration.template
    end

    def messages_content_params
      params.require(:configuration).permit(
        :template_rdv_title_override, :template_rdv_title_by_phone_override,
        :template_applicant_designation_override, :template_rdv_purpose_override
      )
    end

    def overriden_attributes
      messages_content_params.to_h.deep_symbolize_keys.compact_blank
    end
  end
end
