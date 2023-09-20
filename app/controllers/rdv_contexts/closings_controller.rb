module RdvContexts
  class ClosingsController < ApplicationController
    wrap_parameters false
    before_action :set_rdv_context, :set_user, :set_organisation, :set_department, only: [:create, :destroy]

    def create
      authorize @rdv_context, :close?
      return reload_user_show_page if close_rdv_context.success?

      display_error_modal(close_rdv_context.errors)
    end

    def destroy
      authorize @rdv_context, :reopen?
      return reload_user_show_page if @rdv_context.update(closed_at: nil)

      display_error_modal(@rdv_context.errors.full_messages)
    end

    private

    def reload_user_show_page
      return redirect_to department_user_path(@department, @user) if department_level?

      redirect_to organisation_user_path(@organisation, @user)
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
      @rdv_context = RdvContext.find(closing_params[:rdv_context_id])
    end

    def set_user
      @user = policy_scope(User).find(closing_params[:user_id])
    end

    def set_organisation
      return if closing_params[:organisation_id].blank?

      @organisation = policy_scope(Organisation).find(closing_params[:organisation_id])
    end

    def set_department
      @department = policy_scope(Department).find(closing_params[:department_id]) if department_level?
    end

    def closing_params
      params.permit(:rdv_context_id, :user_id, :organisation_id, :department_id)
    end
  end
end
