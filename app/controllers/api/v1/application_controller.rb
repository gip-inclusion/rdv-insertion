module Api
  module V1
    class ApplicationController < ActionController::Base
      skip_before_action :verify_authenticity_token
      respond_to :json
      include AuthorizationConcern
      include RdvSolidaritesSessionConcern
      include RdvSolidaritesAgentConcern
      before_action :validate_session!, :retrieve_agent!, :mark_as_logged_in!

      private

      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

      def record_not_found(_)
        head :not_found
      end
    end
  end
end
