module Api
  module V1
    class ApplicationController < ActionController::Base
      skip_before_action :verify_authenticity_token
      respond_to :json

      include Agents::SignInWithRdvSolidarites
      before_action :retrieve_agent!, :mark_agent_as_logged_in!,
                    :set_current_agent

      include AuthorizationConcern

      private

      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

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
    end
  end
end
