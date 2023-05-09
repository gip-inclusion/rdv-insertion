module RdvContexts
  class ClosingsController < ApplicationController
    wrap_parameters false
    before_action :set_rdv_context, :set_applicant, :set_organisation, :set_department, only: [:create, :destroy]

    def create
      authorize @rdv_context, :close?
      return reload_applicant_show_page if close_rdv_context.success?

      display_error_modal(close_rdv_context.errors)
    end

    def destroy
      authorize @rdv_context, :reopen?
      # updating the status triggers set_status and computes the right status
      return reload_applicant_show_page if @rdv_context.update(closed_at: nil)

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
      @rdv_context = policy_scope(RdvContext).find(closing_params[:rdv_context_id])
    end

    def set_applicant
      @applicant = policy_scope(Applicant).find(closing_params[:applicant_id])
    end

    def set_organisation
      return if closing_params[:organisation_id].blank?

      @organisation = policy_scope(Organisation).find(closing_params[:organisation_id])
    end

    def set_department
      @department = policy_scope(Department).find(closing_params[:department_id]) if department_level?
    end

    def closing_params
      params.permit(:rdv_context_id, :applicant_id, :organisation_id, :department_id)
    end
  end
end
