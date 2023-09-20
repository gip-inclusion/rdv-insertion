module Api
  module V1
    class UsersController < ApplicationController
      before_action :set_users_params, :set_organisation
      include ParamsValidationConcern

      def create_and_invite_many
        if @params_validation_errors.blank?

          users_attributes.each do |attrs|
            CreateAndInviteUserJob.perform_async(
              @organisation.id, attrs.except(:invitation), attrs[:invitation], rdv_solidarites_session.to_h
            )
          end

          render json: { success: true }
        else
          render json: { success: false, errors: @params_validation_errors }, status: :unprocessable_entity
        end
      end

      private

      def users_attributes
        create_and_invite_params.to_h.deep_symbolize_keys[:users].map do |user_attributes|
          user_attributes[:invitation] ||= {}
          user_attributes
        end
      end

      def invitations_attributes
        users_attributes.pluck(:invitation)
      end

      def set_organisation
        @organisation = Organisation.find_by!(rdv_solidarites_organisation_id: params[:rdv_solidarites_organisation_id])
        authorize @organisation, :create_and_invite_users?
      end

      def create_and_invite_params
        params.require(:users)
        params.permit(
          users: [
            :first_name, :last_name, :title, :affiliation_number, :role, :email, :phone_number,
            :nir, :pole_emploi_id,
            :birth_date, :rights_opening_date, :address, :department_internal_id, {
              invitation: [:rdv_solidarites_lieu_id, :motif_category_name]
            }
          ]
        )
      end

      def set_users_params
        # we want POST users/create_and_invite_many to behave like users/create_and_invite_many,
        # so we're changing the payload to have users instead of users
        params[:users] ||= params[:users]
      end
    end
  end
end
