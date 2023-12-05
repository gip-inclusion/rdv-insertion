class RdvContextsController < ApplicationController
  PERMITTED_PARAMS = [:user_id, :motif_category_id].freeze

  before_action :set_user, only: [:create]

  def create
    @rdv_context = RdvContext.new(**rdv_context_params)
    authorize @rdv_context
    if @rdv_context.save
      respond_to do |format|
        format.html { redirect_to(structure_user_path(@user.id, anchor:)) } # html is used for the show page
        format.turbo_stream { replace_new_button_cell_by_rdv_context_status_cell } # turbo is used for index page
      end
    else
      render turbo_stream: turbo_stream.replace(
        "remote_modal", partial: "common/error_modal", locals: {
          errors: @rdv_context.errors.full_messages
        }
      )
    end
  end

  private

  def rdv_context_params
    params.require(:rdv_context).permit(*PERMITTED_PARAMS).to_h.deep_symbolize_keys
  end

  def set_user
    @user = policy_scope(User).find(rdv_context_params[:user_id])
  end

  def replace_new_button_cell_by_rdv_context_status_cell
    render turbo_stream: turbo_stream.replace(
      "user_#{@user.id}_motif_category_#{rdv_context_params[:motif_category_id]}",
      partial: "rdv_context_status_cell",
      locals: { rdv_context: @rdv_context, configuration: nil }
    )
  end

  def anchor
    "rdv_context_#{@rdv_context.id}"
  end
end
