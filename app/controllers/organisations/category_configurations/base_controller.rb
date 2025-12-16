module Organisations
  module CategoryConfigurations
    class BaseController < ApplicationController
      before_action :set_organisation
      before_action :set_category_configuration

      private

      def set_organisation
        @organisation = current_organisation
        authorize @organisation, :configure?
      end

      def set_category_configuration
        @category_configuration = @organisation.category_configurations.find(params[:category_configuration_id])
      end

      def set_department
        @department = @organisation.department
      end
    end
  end
end
