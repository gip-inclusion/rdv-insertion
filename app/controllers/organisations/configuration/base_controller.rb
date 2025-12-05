module Organisations
  module Configuration
    class BaseController < ApplicationController
      layout "organisation_configuration"
      before_action :set_organisation

      private

      def set_organisation
        @organisation = current_organisation
        authorize @organisation, :configure?
      end
    end
  end
end
