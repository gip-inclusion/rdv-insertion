module Api
  module V1
    # rubocop:disable Metrics/ClassLength
    class UsersController < ApplicationController
      include ParamsValidationConcern

      PERMITTED_USER_PARAMS = [
        :first_name, :last_name, :title, :affiliation_number, :role, :email, :phone_number,
        :nir, :france_travail_id, :birth_date, :birth_name, :rights_opening_date, :address, :department_internal_id,
        {
          invitation: [:rdv_solidarites_lieu_id, { motif_category: [:name, :short_name] }],
          referents_to_add: [[:email]],
          tags_to_add: [[:value]]
        }
      ].freeze

      USERS_PER_PAGE = 30
      SEARCHABLE_FIELDS = %w[first_name last_name email phone_number affiliation_number].freeze

      before_action :set_organisation
      before_action :set_users_params, :validate_users_params, only: [:create_and_invite_many]
      before_action :validate_user_params, only: [:create_and_invite, :create]
      before_action :set_user, only: [:invite]

      def index
        @users = search_users
        render json: {
          success: true,
          users: UserBlueprint.render_as_json(@users, view: :with_referents_and_tags),
          pagination: {
            current_page: @users.current_page,
            next_page: @users.next_page,
            prev_page: @users.prev_page,
            total_pages: @users.total_pages,
            total_count: @users.total_count
          }
        }
      end

      def create_and_invite_many
        users_attributes.each do |attrs|
          user_attributes = attrs.except(:invitation)
          invitation_attributes = (attrs[:invitation] || {}).except(:motif_category)
          motif_category_attributes = attrs.dig(:invitation, :motif_category) || {}

          CreateAndInviteUserJob.perform_later(
            @organisation.id,
            user_attributes.merge(creation_origin_attributes),
            invitation_attributes,
            motif_category_attributes
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
          # we call the blueprint explicitely here because we don't want the extended view: we only show relevant infos
          user: UserBlueprint.render_as_json(@user, view: :with_referents_and_tags),
          invitations: InvitationBlueprint.render_as_json(@invitations)
        }
      end

      # this endpoint allows to create a user synchronously
      def create
        @user = upsert_user.user
        return render_errors(["Impossible de créer l'usager: #{upsert_user.errors.join(', ')}"]) if upsert_user.failure?

        render json: {
          success: true,
          user: UserBlueprint.render_as_json(@user, view: :with_referents_and_tags)
        }
      end

      # this endpoint allows to invite a user synchronously
      def invite
        @invitations, @invitation_errors = [[], []]
        invite_user_from_request("sms") if @user.phone_number_is_mobile?
        invite_user_from_request("email") if @user.email?
        return render_errors(@invitation_errors) unless @invitation_errors.empty?

        render json: {
          success: true,
          user: UserBlueprint.render_as_json(@user, view: :with_referents_and_tags),
          invitations: InvitationBlueprint.render_as_json(@invitations)
        }
      end

      private

      def search_users
        users = @organisation.users.active
        users = apply_search_filter(users) if search_params[:search_query].present?
        users.page(search_params[:page]).per(USERS_PER_PAGE)
      end

      def apply_search_filter(users)
        query = "%#{search_params[:search_query]}%"
        search_conditions = SEARCHABLE_FIELDS.map { |field| "#{field} ILIKE ?" }.join(" OR ")
        search_values = Array.new(SEARCHABLE_FIELDS.length, query)

        users.where(search_conditions, *search_values)
      end

      def search_params
        params.permit(:search_query, :page)
      end

      def set_user
        @user = @organisation.users.find(params[:id])
      end

      def upsert_user
        @upsert_user ||= Users::Upsert.call(
          user_attributes: user_attributes.merge(creation_origin_attributes), organisation: @organisation
        )
      end

      def invite_user_by(format)
        invite_user_service = call_invite_user_service_by(format)
        unless invite_user_service.success?
          @invitation_errors <<
            "Erreur en envoyant l'invitation par #{format}: #{invite_user_service.errors.join(', ')}"
        end
        @invitations << invite_user_service.invitation
      end

      def invite_user_from_request(format)
        invitation_attrs = (invitation_params[:invitation] || {}).except(:motif_category)
        motif_category_attrs = invitation_params.dig(:invitation, :motif_category) || {}

        invite_user_service = call_invite_user_service_by(format, invitation_attrs, motif_category_attrs)

        unless invite_user_service.success?
          @invitation_errors <<
            "Erreur en envoyant l'invitation par #{format}: #{invite_user_service.errors.join(', ')}"
        end
        @invitations << invite_user_service.invitation
      end

      def call_invite_user_service_by(format, custom_invitation_attrs = nil, custom_motif_category_attrs = nil)
        invite_attrs = custom_invitation_attrs || invitation_attributes
        motif_attrs = custom_motif_category_attrs || motif_category_attributes

        InviteUser.call(
          user: @user,
          organisations: [@organisation],
          motif_category_attributes: motif_attrs,
          invitation_attributes: invite_attrs.merge(format: format)
        )
      end

      def users_attributes
        users_params.map do |user_attributes|
          user_attributes.to_h.deep_symbolize_keys.tap { |attrs| attrs[:invitation] ||= {} }
        end
      end

      def user_attributes
        user_params.except(:invitation)
      end

      def creation_origin_attributes
        {
          created_through: "rdv_insertion_api",
          created_from_structure_type: "Organisation",
          created_from_structure_id: @organisation.id
        }
      end

      def invitation_attributes
        (user_params[:invitation] || {}).except(:motif_category)
      end

      def motif_category_attributes
        user_params.dig(:invitation, :motif_category) || {}
      end

      def user_params
        params.expect(user: PERMITTED_USER_PARAMS).to_h.deep_symbolize_keys
      end

      def set_organisation
        @organisation = Organisation.find_by!(rdv_solidarites_organisation_id: params[:rdv_solidarites_organisation_id])
        authorize @organisation, :create_and_invite_users?
      end

      def users_params
        params.expect(users: [PERMITTED_USER_PARAMS])
      end

      def set_users_params
        # we want POST applicants/create_and_invite_many to behave like users/create_and_invite_many,
        # so we're changing the payload to have users instead of applicants
        params[:users] ||= params[:applicants]
      end

      def invitation_params
        params.permit(invitation: [:rdv_solidarites_lieu_id, { motif_category: [:name, :short_name] }])
      end
    end
    # rubocop: enable Metrics/ClassLength
  end
end
