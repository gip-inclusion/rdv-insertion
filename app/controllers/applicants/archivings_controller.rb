module Applicants
  class ArchivingsController < ApplicationController
    wrap_parameters false
    before_action :set_applicant
    before_action :set_archived_at, only: [:create]

    def create
      toggle_archive_applicant_and_render
    end

    def destroy
      toggle_archive_applicant_and_render
    end

    private

    def toggle_archive_applicant_and_render
      if toggle_archive_applicant.success?
        render json: { success: true, applicant: @applicant }
      else
        render json: { success: false, errors: toggle_archive_applicant.errors }, status: :unprocessable_entity
      end
    end

    def toggle_archive_applicant
      @toggle_archive_applicant ||= Applicants::ToggleArchiveApplicant.call(
        applicant: @applicant,
        rdv_solidarites_session: rdv_solidarites_session,
        archiving_reason: archiving_params[:archiving_reason],
        archived_at: @archived_at
      )
    end

    def set_applicant
      @applicant = Applicant.find(params[:applicant_id])
      authorize @applicant, :update?
    end

    def set_archived_at
      @archived_at = Time.zone.now
    end

    def archiving_params
      params.permit(:archiving_reason, :applicant_id)
    end
  end
end
