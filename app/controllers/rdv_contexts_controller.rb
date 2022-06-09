class RdvContextsController < ApplicationController
  before_action :set_applicant, :set_rdv_context, only: [:create]

  def create
    if @rdv_context.save
      respond_to do |format|
        format.turbo_stream
      end
    else
      flash[:error] = @rdv_context.errors.full_messages.to_sentence
      redirect_to department_applicant_path(@applicant.department, @applicant)
    end
  end

  private

  def rdv_context_params
    params.require(:rdv_context).permit(:motif_category)
  end

  def set_rdv_context
    @rdv_context = RdvContext.find_or_initialize_by(
      applicant: @applicant,
      motif_category: rdv_context_params[:motif_category]
    )
    authorize @rdv_context
  end

  def set_applicant
    @applicant = Applicant.find(params[:applicant_id])
  end
end
