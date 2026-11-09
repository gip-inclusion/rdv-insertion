module Api
  module PlateformeInclusion
    class UsersController < ActionController::API
      include ActionController::HttpAuthentication::Token::ControllerMethods
      include RateLimitingConcern
      include IpWhitelistConcern

      before_action :authenticate_plateforme_inclusion!, :ensure_ip_comes_from_clever_cloud
      override_rate_limit limit: RATE_LIMITS[:plateforme_inclusion],
                          by: -> { "#{action_name}:#{Digest::SHA256.hexdigest(params[:nir].to_s)}" }
      override_rate_limit limit: ENV.fetch("RATE_LIMIT_PLATEFORME_INCLUSION_GLOBAL", 600).to_i, by: -> { action_name }

      rescue_from ActionController::ParameterMissing, with: :render_invalid_nir
      rescue_from ActiveRecord::RecordNotFound, with: :render_user_not_found
      rescue_from ActiveRecord::SoleRecordExceeded, with: :render_several_users_found

      def search
        Rails.logger.info("[PlateformeInclusion] User returned: user_id=#{user.id} ip=#{request.remote_ip}")
        render json: { user: ::PlateformeInclusion::UserBlueprint.render_as_json(user) }
      end

      private

      def authenticate_plateforme_inclusion!
        return if authenticate_with_http_token { |token| valid_token?(token) }

        Sentry.capture_message(
          "Plateforme de l'inclusion search without a valid token", extra: { ip: request.remote_ip }
        )
        render json: { errors: ["Token d'authentification invalide"] }, status: :unauthorized
      end

      def valid_token?(token)
        ActiveSupport::SecurityUtils.secure_compare(token, ENV.fetch("PLATEFORME_INCLUSION_API_TOKEN"))
      end

      def user
        @user ||= users.preload(
          :referents, :tags, :archives,
          organisations: :department,
          follow_ups: [
            :motif_category, :invitations,
            { participations: { rdv: [:agents, :lieu, { motif: :motif_category }, { organisation: :department }] } }
          ]
        ).sole
      end

      def users
        User.active.where(nir: params.expect(:nir))
      end

      def render_invalid_nir
        render json: { errors: ["Le paramètre nir doit contenir un seul NIR"] }, status: :bad_request
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
