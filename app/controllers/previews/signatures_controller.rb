module Previews
  class SignaturesController < ApplicationController
    before_action :set_messages_configuration

    def show
      render layout: false
    end

    private

    def set_messages_configuration
      @messages_configuration = MessagesConfiguration.find(params[:id])
      @organisation = @messages_configuration.organisation
      authorize @organisation, :configure?
    end
  end
end