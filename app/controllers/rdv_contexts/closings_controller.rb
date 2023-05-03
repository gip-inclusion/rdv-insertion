module RdvContexts
  class ClosingsController < ApplicationController
    wrap_parameters false
    before_action :set_rdv_context, :set_applicant, :set_organisation, :set_department, only: [:create, :destroy]

    def create
      if close_rdv_context.success?
        return redirect_to department_applicant_path(@department, @applicant) if department_level?

        redirect_to organisation_applicant_path(@organisation, @applicant)
      else
        render turbo_stream: turbo_stream.replace(
          "remote_modal", partial: "common/error_modal", locals: {
            errors: close_rdv_context.errors
          }
        )
      end
    end

    def destroy
      if @rdv_context.update(status: "not_invited") # this will trigger set_status method and compute the right status
        return redirect_to department_applicant_path(@department, @applicant) if department_level?

        redirect_to organisation_applicant_path(@organisation, @applicant)
      else
        render turbo_stream: turbo_stream.replace(
          "remote_modal", partial: "common/error_modal", locals: {
            errors: @rdv_context.errors.full_messages
          }
        )
      end
    end

    private

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
      @organisation = Organisation.find(params[:organisation_id])
    end

    def set_department
      @department = Department.find(params[:department_id]) if department_level?
    end

    def archiving_params
      params.permit(:rdv_context_id, :applicant_id, :organisation_id, :department_id)
    end
  end
end
