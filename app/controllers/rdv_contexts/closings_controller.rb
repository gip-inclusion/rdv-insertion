module RdvContexts
  class ClosingsController < ApplicationController
    wrap_parameters false
    before_action :set_rdv_context, :set_applicant, :set_organisation, :set_department, only: [:create, :destroy]

    def create
      return reload_applicant_show_page if close_rdv_context.success?

      display_error_modal(close_rdv_context.errors)
    end

    def destroy
      # updating the status triggers set_status and computes the right status
      return reload_applicant_show_page if @rdv_context.update(status: "not_invited", closed_at: nil)

      display_error_modal(@rdv_context.errors.full_messages)
    end

    private

    def reload_applicant_show_page
      return redirect_to department_applicant_path(@department, @applicant) if department_level?

      redirect_to organisation_applicant_path(@organisation, @applicant)
    end

    def display_error_modal(errors)
      render turbo_stream: turbo_stream.replace(
        "remote_modal", partial: "common/error_modal", locals: {
          errors: errors
        }
      )
    end

    def close_rdv_context
      @close_rdv_context ||= RdvContexts::Close.call(rdv_context: @rdv_context)
    end

    def set_rdv_context
      @rdv_context = RdvContext.find(params[:rdv_context_id])
    end

    def set_applicant
      @applicant = Applicant.find(params[:applicant_id])
    end

    def set_organisation
      @organisation = Organisation.find(params[:organisation_id]) if params[:organisation_id].present?
    end

    def set_department
      @department = Department.find(params[:department_id]) if department_level?
    end

    def archiving_params
      params.permit(:rdv_context_id, :applicant_id, :organisation_id, :department_id)
    end
  end
end
