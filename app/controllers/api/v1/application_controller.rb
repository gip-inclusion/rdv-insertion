module Api
  module V1
    class ApplicationController < ActionController::Base
      skip_before_action :verify_authenticity_token
      respond_to :json

      include Agents::SignIn
      before_action :validate_session!, :retrieve_agent!, :mark_agent_as_logged_in!
      alias current_agent authenticated_agent
      alias rdv_solidarites_session new_rdv_solidarites_session

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
    end
  end
end
