module Organisations
  class MessagesConfigurationsController < ApplicationController
    PERMITTED_PARAMS = [
      { direction_names: [] }, :sender_city, :letter_sender_name, { signature_lines: [] },
      { displayed_logos: [] }, :help_address, :sms_sender_name, :signature_image,
      :remove_signature_image
    ].freeze

    before_action :set_organisation, :set_messages_configuration

    def show; end

    def edit; end

    def update
      @messages_configuration.assign_attributes(messages_configuration_params)
      if @messages_configuration.save
        redirect_to organisation_messages_configuration_path(@organisation, @messages_configuration)
      else
        turbo_stream_display_error_modal(@messages_configuration.errors.full_messages)
      end
    end

    private

    def messages_configuration_params
      params.expect(messages_configuration: PERMITTED_PARAMS).to_h.deep_symbolize_keys
    end

    def set_messages_configuration
      @messages_configuration = @organisation.messages_configuration
    end

    def set_organisation
      @organisation = Organisation.find(params[:organisation_id])
      authorize @organisation, :configure?
    end
  end
end
