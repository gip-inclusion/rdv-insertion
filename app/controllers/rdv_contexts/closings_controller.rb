module RdvContexts
  class ClosingsController < ApplicationController
    wrap_parameters false
    before_action :set_rdv_context, only: [:create, :destroy]

    def create
      authorize @rdv_context, :close?
      if close_rdv_context.success?
        redirect_to user_rdv_contexts_path(user_id: @rdv_context.user_id, anchor:)
      else
        turbo_stream_display_error_modal(@rdv_context.errors.full_messages)
      end
    end

    def destroy
      authorize @rdv_context, :reopen?
      if @rdv_context.update(closed_at: nil)
        redirect_to user_rdv_contexts_path(user_id: @rdv_context.user_id, anchor:)
      else
        turbo_stream_display_error_modal(@rdv_context.errors.full_messages)
      end
    end

    private

    def close_rdv_context
      @close_rdv_context ||= RdvContexts::Close.call(rdv_context: @rdv_context)
    end

    def set_rdv_context
      @rdv_context = RdvContext.find(closing_params[:rdv_context_id])
    end

    def closing_params
      params.permit(:rdv_context_id)
    end

    def anchor
      "rdv_context_#{@rdv_context.id}"
    end
  end
end
