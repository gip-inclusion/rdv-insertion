class RdvSolidarites::InvalidSessionError < StandardError; end

module Api
  module V1
    class ApplicationController < ActionController::Base
      skip_before_action :verify_authenticity_token
      respond_to :json
      before_action :validate_session!
      include Pundit

      private

      def pundit_user
        current_agent
      end

      def current_agent
        @current_agent ||= Agent.find_by!(email: rdv_solidarites_session.uid)
      end

      def validate_session!
        raise RdvSolidarites::InvalidSessionError unless rdv_solidarites_session.valid?
      end

      def rdv_solidarites_session
        @rdv_solidarites_session ||= RdvSolidaritesSession.new(
          uid: request.headers["uid"],
          client: request.headers["client"],
          access_token: request.headers["access-token"]
        )
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

      def invalid_session
        render(
          json: { errors: ["Les identifiants de session RDV-Solidarités sont invalides"] },
          status: :unauthorized
        )
      end

      def record_not_found(_)
        head :not_found
      end
    end
  end
end
