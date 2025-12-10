module Organisations
  module Configuration
    class BaseController < ApplicationController
      layout "organisation_configuration"
      before_action :set_organisation, :set_department

      private

      def set_organisation
        @organisation = current_organisation
        authorize @organisation, :configure?
      end

      def set_department
        @department = @organisation.department
      end
    end
  end
end
