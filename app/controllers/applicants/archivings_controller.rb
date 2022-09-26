module Applicants
  class ArchivingsController < ApplicationController
    wrap_parameters false
    before_action :set_applicant

    def create
      if archive_applicant.success?
        render json: { success: true, applicant: @applicant }
      else
        render json: { success: false, errors: archive_applicant.errors }, status: :unprocessable_entity
      end
    end

    def destroy
      if @applicant.update(archiving_reason: nil, archived_at: nil)
        render json: { success: true }
      else
        render json: { success: false, errors: @applicant.errors.full_messages }
      end
    end

    private

    def archive_applicant
      @archive_applicant ||= Applicants::Archive.call(
        applicant: @applicant,
        rdv_solidarites_session: rdv_solidarites_session,
        archiving_reason: archiving_params[:archiving_reason],
        archived_at: Time.zone.now
      )
    end

    def set_applicant
      @applicant = Applicant.find(params[:applicant_id])
      authorize @applicant, :update?
    end

    def archiving_params
      params.permit(:archiving_reason, :applicant_id)
    end
  end
end
