module Applicants
  class ArchivingsController < ApplicationController
    wrap_parameters false
    before_action :set_applicant

    def create
      if @applicant.update(archiving_reason: archiving_params[:archiving_reason], archived_at: Time.zone.now)
        invalidate_invitations
        render json: { success: true }
      else
        render json: { success: false, errors: @applicant.errors.full_messages }
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

    def set_applicant
      @applicant = Applicant.find(params[:applicant_id])
      authorize @applicant, :update?
    end

    def archiving_params
      params.permit(:archiving_reason)
    end

    def invalidate_invitations
      @applicant.invitations.each do |invitation|
        InvalidateInvitationJob.perform_async(invitation.id)
      end
    end
  end
end
