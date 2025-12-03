module Organisations
  module Configuration
    class TagsController < ApplicationController
      before_action :set_organisation

      def show
        @tab = "tags"
      end

      private

      def set_organisation
        @organisation = current_organisation
        authorize @organisation, :configure?
      end
    end
  end
end
