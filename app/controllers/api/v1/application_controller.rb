module Api
  module V1
    class ApplicationController < ActionController::Base
      skip_before_action :verify_authenticity_token
      respond_to :json
      include Pundit
      include RdvSolidaritesSessionConcern
      before_action :validate_session!

      private

      def pundit_user
        current_agent
      end

      def current_agent
        @current_agent ||= Agent.find_by!(email: rdv_solidarites_session.uid)
      end

      rescue_from RdvSolidarites::InvalidSessionError, with: :invalid_session
      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
      rescue_from Pundit::NotAuthorizedError, with: :forbidden

      def forbidden(_)
        render(
          status: :forbidden,
          json: {
            errors: ["Vous n'êtes pas autorisé à effectuer cette action"]
          }
        )
      end

      def record_not_found(_)
        head :not_found
      end
    end
  end
end
