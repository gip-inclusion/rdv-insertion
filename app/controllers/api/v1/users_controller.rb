module Api
  module V1
    class UsersController < ApplicationController
      include ParamsValidationConcern

      PERMITTED_USER_PARAMS = [
        :first_name, :last_name, :title, :affiliation_number, :role, :email, :phone_number,
        :nir, :pole_emploi_id,
        :birth_date, :rights_opening_date, :address, :department_internal_id, {
          invitation: [:rdv_solidarites_lieu_id, { motif_category: [:name, :short_name, :id] }]
        }
      ].freeze

      before_action :set_organisation
      before_action :set_users_params, :validate_users_params, only: :create_and_invite_many
      before_action :validate_user_params, only: :create_and_invite

      def create_and_invite_many
        users_attributes.each do |attrs|
          user_attributes = attrs.except(:invitation)
          invitation_attributes = (attrs[:invitation] || {}).except(:motif_category)
          motif_category_attributes = attrs.dig(:invitation, :motif_category) || {}

          CreateAndInviteUserJob.perform_async(
            @organisation.id, user_attributes, invitation_attributes, motif_category_attributes,
            rdv_solidarites_session.to_h
          )
        end
        render json: { success: true }
      end

      # this endpoint allows to create and invite a user synchronously
      def create_and_invite
        @user = upsert_user.user
        return render_errors(["Impossible de créer l'usager: #{upsert_user.errors.join(', ')}"]) if upsert_user.failure?

        @invitations, @invitation_errors = [[], []]
        invite_user_by("sms") if @user.phone_number_is_mobile?
        invite_user_by("email") if @user.email?
        return render_errors(@invitation_errors) unless @invitation_errors.empty?

        render json: {
          success: true,
          # we call the blueprint explicitely here because we don't want the extended view
          user: UserBlueprint.render_as_json(@user),
          invitations: InvitationBlueprint.render_as_json(@invitations)
        }
      end

      private

      def upsert_user
        @upsert_user ||= Users::Upsert.call(
          user_attributes: user_attributes, organisation: @organisation, rdv_solidarites_session:
        )
      end

      def invite_user_by(format)
        invite_user_service = call_invite_user_service_by("sms")
        unless invite_user_service.success?
          @invitation_errors <<
            "Erreur en envoyant l'invitation par #{format}: #{invite_user_service.errors.join(', ')}"
        end
        @invitations << invite_user_service.invitation
      end

      def call_invite_user_service_by(format)
        InviteUser.call(
          user: @user, organisations: [@organisation], motif_category_attributes:, rdv_solidarites_session:,
          invitation_attributes: invitation_attributes.merge(format:, help_phone_number: @organisation.phone_number)
        )
      end

      def users_attributes
        users_params.to_h.deep_symbolize_keys[:users].map do |user_attributes|
          user_attributes[:invitation] ||= {}
          user_attributes
        end
      end

      def user_attributes
        user_params.except(:invitation)
      end

      def invitation_attributes
        (user_params[:invitation] || {}).except(:motif_category)
      end

      def motif_category_attributes
        user_attributes.dig(:invitation, :motif_category) || {}
      end

      def user_params
        params.require(:user).permit(*PERMITTED_USER_PARAMS).to_h.deep_symbolize_keys
      end

      def set_organisation
        @organisation = Organisation.find_by!(rdv_solidarites_organisation_id: params[:rdv_solidarites_organisation_id])
        authorize @organisation, :create_and_invite_users?
      end

      def users_params
        params.require(:users)
        params.permit(users: PERMITTED_USER_PARAMS)
      end

      def set_users_params
        # we want POST applicants/create_and_invite_many to behave like users/create_and_invite_many,
        # so we're changing the payload to have users instead of users
        params[:users] ||= params[:applicants]
      end
    end
  end
end
