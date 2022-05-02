module Api
  module V1
    class ApplicantsController < ApplicationController
      before_action :set_organisation
      include ParamsValidationConcern

      def create_and_invite_many
        if @params_validation_errors.blank?

          applicants_attributes.each do |attrs|
            CreateAndInviteApplicantJob.perform_async(
              @organisation.id, attrs.except(:invitation), attrs[:invitation], rdv_solidarites_session.to_h
            )
          end

          render json: { success: true }
        else
          render json: { success: false, errors: @params_validation_errors }, status: :unprocessable_entity
        end
      end

      private

      def applicants_attributes
        create_and_invite_params.to_h.deep_symbolize_keys[:applicants]
      end

      def invitations_params
        applicants_attributes.pluck(:invitation)
      end

      def set_organisation
        @organisation = Organisation.find_by!(rdv_solidarites_organisation_id: params[:rdv_solidarites_organisation_id])
        authorize @organisation, :create_and_invite_applicants?
      end

      def create_and_invite_params
        params.require(:applicants)
        params.permit(
          applicants: [
            :first_name, :last_name, :title, :affiliation_number, :role, :email, :phone_number,
            :birth_date, :rights_opening_date, :address, :department_internal_id, { invitation: {} }
          ]
        )
      end
    end
  end
end
