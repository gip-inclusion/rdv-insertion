class RdvContextsController < ApplicationController
  before_action :set_contexts, only: [:new]
  before_action :set_applicant, only: [:new, :create]
  before_action :set_rdv_context, only: [:create]

  def new
    @rdv_context = RdvContext.new(applicant: @applicant)
    authorize @rdv_context
  end

  def create
    if @rdv_context.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to department_applicant_path(@applicant.department, @applicant) }
      end
    else
      flash.now[:error] = @rdv_context.errors.full_message.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  private

  def rdv_context_params
    params.require(:rdv_context).permit(:context)
  end

  def set_rdv_context
    @rdv_context = RdvContext.find_or_initialize_by(
      applicant: @applicant,
      context: rdv_context_params[:context]
    )
  end

  def set_contexts
    @contexts = \
      if organisation.present?
        organisation.configurations.map(&:context)
      elsif department.present?
        department.configurations.map(&:context)
      else
        ::Configuration.contexts.keys
      end
  end

  def set_applicant
    @applicant = Applicant.find(params[:applicant_id])
  end

  def organisation
    @organisation ||= \
      params[:organisation_id].present? ? Organisation.find(params[:organisation_id]) : nil
  end

  def department
    @department ||= \
      params[:department_id].present? ? Department.find(params[:department_id]) : nil
  end
end
