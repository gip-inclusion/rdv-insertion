module Api
  module V1
    class ApplicationController < ActionController::Base
      skip_before_action :verify_authenticity_token
      respond_to :json

      before_action :validate_rdv_solidarites_credentials!, :retrieve_agent!, :mark_agent_as_logged_in!,
                    :set_current_agent
      after_action :log_api_call

      include AuthorizationConcern
      include Api::V1::PaperTrailConcern
      include AgentLoggingConcern

      private

      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

      def validate_rdv_solidarites_credentials!
        return if rdv_solidarites_credentials.valid?

        render(
          json: { errors: ["Les identifiants de session RDV-Solidarités sont invalides"] },
          status: :unauthorized
        )
      end

      def rdv_solidarites_credentials
        @rdv_solidarites_credentials ||= RdvSolidaritesCredentials.new(
          uid: request.headers["uid"],
          client: request.headers["client"],
          access_token: request.headers["access-token"]
        )
      end

      def retrieve_agent!
        return if authenticated_agent

        render json: { success: false, errors: ["L'agent ne fait pas partie d'une organisation sur RDV-Insertion"] },
               status: :forbidden
      end

      def mark_agent_as_logged_in!
        return if authenticated_agent.update(last_sign_in_at: Time.zone.now)

        render json: { success: false, errors: authenticated_agent.errors.full_messages }, status: :unprocessable_entity
      end

      def authenticated_agent
        @authenticated_agent ||= Agent.find_by(email: rdv_solidarites_credentials.email)
      end

      def record_not_found(exception)
        render json: { not_found: exception.model }, status: :not_found
      end

      def render_errors(error_messages)
        errors = error_messages.map { |error_msg| { error_details: error_msg } }
        render json: { success: false, errors: }, status: :unprocessable_entity
      end

      def set_current_agent
        Current.agent ||= current_agent
      end

      def current_agent
        authenticated_agent
      end

      def log_api_call
        ApiCall.create!(
          method: request.method,
          path: request.fullpath,
          host: request.host,
          controller_name: controller_name,
          action_name: action_name,
          agent_id: current_agent&.id
        )
      rescue StandardError => e
        Sentry.capture_exception(
          e,
          extra: {
            method: request.method,
            path: request.fullpath,
            agent_id: current_agent&.id
          }
        )
      end
    end
  end
end
