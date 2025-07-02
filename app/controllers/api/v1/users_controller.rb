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
            user_attributes,
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
        invite_user_by("sms") if @user.phone_number_is_mobile?
        invite_user_by("email") if @user.email?
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
        users = users.search_by_text(params[:search_query]).reorder("") if params[:search_query].present?
        users.page(params[:page])
      end

      def set_user
        @user = @organisation.users.find(params[:id])
      end

      def upsert_user
        @upsert_user ||= Users::Upsert.call(
          user_attributes: user_attributes, organisation: @organisation
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

      def call_invite_user_service_by(format)
        InviteUser.call(
          user: @user,
          organisations: [@organisation],
          motif_category_attributes: motif_category_attributes,
          invitation_attributes: invitation_attributes.merge(format: format)
        )
      end

      def users_attributes
        users_params.map do |user_attributes|
          user_attributes.to_h.deep_symbolize_keys.merge(creation_origin_attributes).tap do |attrs|
            attrs[:invitation] ||= {}
            convert_tags_to_add_to_tag_users_attributes(attrs)
          end
        end
      end

      def user_attributes
        user_params.except(:invitation).merge(creation_origin_attributes).tap do |attrs|
          convert_tags_to_add_to_tag_users_attributes(attrs)
        end
      end

      def creation_origin_attributes
        {
          created_through: "rdv_insertion_api",
          created_from_structure_type: "Organisation",
          created_from_structure_id: @organisation.id
        }
      end

      def invitation_attributes
        source_params = action_name == "invite" ? invitation_params : user_params
        (source_params[:invitation] || {}).except(:motif_category)
      end

      def motif_category_attributes
        source_params = action_name == "invite" ? invitation_params : user_params
        source_params.dig(:invitation, :motif_category) || {}
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

      def convert_tags_to_add_to_tag_users_attributes(attrs)
        return if attrs[:tags_to_add].blank?

        # Convert tags_to_add to tag_users_attributes for direct tag assignment
        # This uses the existing tag_users_attributes= method which works with tag IDs directly
        tag_users_attributes = attrs[:tags_to_add].map do |tag_attributes|
          tag = @organisation.tags.find_by!(value: tag_attributes[:value])
          { tag_id: tag.id } if tag
        end.compact

        attrs[:tag_users_attributes] = tag_users_attributes
        attrs.delete(:tags_to_add)
      end
    end
    # rubocop: enable Metrics/ClassLength
  end
end
