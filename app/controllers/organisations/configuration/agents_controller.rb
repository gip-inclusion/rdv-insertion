module Organisations
  module Configuration
    class AgentsController < ApplicationController
      before_action :set_organisation

      def show
        @tab = "agents"
      end

      private

      def set_organisation
        @organisation = current_organisation
        authorize @organisation, :configure?
      end
    end
  end
end
