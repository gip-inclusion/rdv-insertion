module Applicants
  class SearchesController < ApplicationController
    before_action :set_organisations, :search_applicants, only: [:create]

    def create
      render json: { success: true, applicants: @applicants }
    end

    private

    def search_applicants
      @applicants =
        Applicant
        .active
        .where(id: search_in_all_applicants.ids + search_in_department_organisations.ids)
        .preload(
          :rdvs, :agents,
          invitations: :rdv_context,
          rdv_contexts: [:participations, :motif_category],
          organisations: [:motif_categories, :department, :configurations]
        ).distinct
    end

    def search_in_all_applicants
      Applicant
        .where(nir: applicants_params[:nirs])
        .or(Applicant.where(email: applicants_params[:emails]))
        .or(Applicant.where(phone_number: formatted_phone_numbers))
        .select(:id)
    end

    def formatted_phone_numbers
      applicants_params[:phone_numbers].map do |phone_number|
        PhoneNumberHelper.format_phone_number(phone_number)
      end.compact
    end

    def search_in_department_organisations
      Applicant
        .joins(:organisations)
        .where(organisations: @organisations, department_internal_id: applicants_params[:department_internal_ids])
        .or(
          Applicant
          .joins(:organisations)
          .where(organisations: @organisations, uid: applicants_params[:uids])
        ).select(:id)
    end

    def applicants_params
      params.require(:applicants).permit(
        nirs: [], department_internal_ids: [], uids: [], emails: [], phone_numbers: []
      ).to_h.deep_symbolize_keys
    end

    def set_organisations
      @organisations = Organisation.where(department_id: params[:department_id])
    end
  end
end
