module Api
  module PlateformeInclusion
    class UsersController < ActionController::API
      include ActionController::HttpAuthentication::Token::ControllerMethods
      include RateLimitingConcern

      before_action :authenticate_plateforme_inclusion!

      rescue_from ActiveRecord::RecordNotFound, with: :render_user_not_found
      rescue_from ActiveRecord::SoleRecordExceeded, with: :render_several_users_found

      def search
        render json: { user: ::PlateformeInclusion::UserBlueprint.render_as_json(user) }
      end

      private

      def authenticate_plateforme_inclusion!
        authenticate_or_request_with_http_token do |token|
          ActiveSupport::SecurityUtils.secure_compare(token, ENV.fetch("PLATEFORME_INCLUSION_API_TOKEN"))
        end
      end

      def user
        users.preload(
          :referents, :tags, :archives,
          organisations: :department,
          follow_ups: [
            :motif_category, :invitations,
            { participations: { rdv: [:agents, :lieu, { motif: :motif_category }, { organisation: :department }] } }
          ]
        ).sole
      end

      def users
        User.active.where(nir: params.require(:nir))
      end

      def render_user_not_found
        render json: { errors: ["Aucun usager ne correspond à ce NIR"] }, status: :not_found
      end

      def render_several_users_found
        Sentry.capture_message(
          "Several users match the NIR searched by plateforme de l'inclusion", extra: { user_ids: users.ids }
        )
        render json: { errors: ["Plusieurs usagers correspondent à ce NIR"] }, status: :conflict
      end
    end
  end
end
