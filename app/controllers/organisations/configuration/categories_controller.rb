module Organisations
  module Configuration
    class CategoriesController < ApplicationController
      before_action :set_organisation

      def show
        @tab = "categories"
      end

      private

      def set_organisation
        @organisation = current_organisation
        authorize @organisation, :configure?
      end
    end
  end
end
