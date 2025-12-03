module Organisations
  module Configuration
    class MessagesController < ApplicationController
      before_action :set_organisation

      def show
        @tab = "messages"
      end

      private

      def set_organisation
        @organisation = current_organisation
        authorize @organisation, :configure?
      end
    end
  end
end
