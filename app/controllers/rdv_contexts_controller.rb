class RdvContextsController < ApplicationController
  before_action :set_applicant, :set_configuration, :set_motif_category,
                :set_organisation, :set_department, only: [:create]

  def create
    @rdv_context = RdvContext.new(applicant: @applicant, motif_category: @motif_category)
    if @rdv_context.save
      respond_to do |format|
        format.html { redirect_to(after_save_path) } # html is used for the show page
        format.turbo_stream { replace_new_button_by_rdv_context_status } # turbo is used for index page
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

  def set_applicant
    @applicant = policy_scope(Applicant).find(params[:applicant_id])
  end

  def set_configuration
    @configuration = ::Configuration.find(params[:configuration_id])
  end

  def set_motif_category
    @motif_category = @configuration.motif_category
  end

  def set_organisation
    @organisation = @configuration.organisation
  end

  def set_department
    @department = @organisation.department
  end

  def replace_new_button_by_rdv_context_status
    render turbo_stream: turbo_stream.replace(
      "applicant_#{@applicant.id}_motif_category_#{@motif_category.id}",
      partial: "rdv_context_status",
      locals: { rdv_context: @rdv_context, configuration: @configuration }
    )
  end

  def after_save_path
    return department_applicant_path(@department, @applicant, anchor: anchor) if department_level?

    organisation_applicant_path(@organisation, @applicant, anchor: anchor)
  end

  def anchor
    "rdv_context_#{@rdv_context.id}"
  end
end
