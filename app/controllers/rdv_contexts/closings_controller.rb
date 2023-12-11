module RdvContexts
  class ClosingsController < ApplicationController
    wrap_parameters false
    before_action :set_rdv_context, only: [:create, :destroy]

    def create
      authorize @rdv_context, :close?
      if close_rdv_context.success?
        redirect_to structure_user_path(@rdv_context.user_id)
      else
        display_error_modal(@rdv_context.errors.full_messages)
      end
    end

    def destroy
      authorize @rdv_context, :reopen?
      if @rdv_context.update(closed_at: nil)
        redirect_to structure_user_path(@rdv_context.user_id)
      else
        display_error_modal(@rdv_context.errors.full_messages)
      end
    end

    private

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

    def closing_params
      params.permit(:rdv_context_id)
    end
  end
end
