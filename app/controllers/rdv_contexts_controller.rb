class RdvContextsController < ApplicationController
  PERMITTED_PARAMS = [:applicant_id, :motif_category_id].freeze

  include SetOrganisationAndDepartmentConcern
  include SetAllConfigurationsConcern
  include SetCurrentAgentRolesConcern
  include BackToListConcern
  include RdvContexts::Filterable
  include ExtractableConcern

  before_action :set_organisation, :set_department, :set_organisations, :set_all_configurations,
                :set_current_agent_roles, :set_current_configuration, :set_current_motif_category,
                :set_applicants, :set_rdv_contexts, :filter_rdv_contexts, :order_rdv_contexts, :set_convocation_motifs,
                :store_back_to_list_url, :set_back_to_list_url, :set_extraction_url,
                for: :index
  before_action :set_applicant, :set_organisation, :set_department, only: [:create]

  def index
    respond_to do |format|
      format.html
      format.csv { send_csv }
    end
  end

  def create
    @rdv_context = RdvContext.new(**rdv_context_params)
    authorize @rdv_context
    if @rdv_context.save
      respond_to do |format|
        format.html { redirect_to(after_save_path) } # html is used for the show page
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

  def set_applicant
    @applicant = policy_scope(Applicant).find(rdv_context_params[:applicant_id])
  end

  def replace_new_button_cell_by_rdv_context_status_cell
    render turbo_stream: turbo_stream.replace(
      "applicant_#{@applicant.id}_motif_category_#{rdv_context_params[:motif_category_id]}",
      partial: "rdv_context_status_cell",
      locals: { rdv_context: @rdv_context, configuration: nil }
    )
  end

  def after_save_path
    return department_applicant_path(@department, @applicant, anchor: anchor) if department_level?

    organisation_applicant_path(@organisation, @applicant, anchor: anchor)
  end

  def anchor
    "rdv_context_#{@rdv_context.id}"
  end

  def set_rdv_contexts
    @rdv_contexts = RdvContext
                    .preload(:applicant, :notifications, :invitations)
                    .where(applicant_id: @applicants.ids, motif_category: @current_motif_category)
                    .where.not(status: "closed")
                    .distinct
    @statuses_count = @rdv_contexts.group(:status).count
  end

  def set_applicants
    @applicants = policy_scope(Applicant)
                  .active
                  .where(department_level? ? { organisations: @organisations } : { organisations: @organisation })
                  .where.not(id: @department.archived_applicants.ids)
  end

  def set_current_configuration
    @current_configuration =
      @all_configurations.find { |c| c.motif_category_id == params[:motif_category_id].to_i }
  end

  def set_current_motif_category
    @current_motif_category = @current_configuration.motif_category
  end

  def set_convocation_motifs
    return unless @current_configuration&.convene_applicant?

    convocation_motifs = Motif.includes(:organisation).active.where(
      organisation_id: department_level? ? @organisations.ids : @organisation.id,
      motif_category: @current_motif_category
    ).select(&:convocation?)

    @convocation_motifs_by_applicant = @applicants.index_with do |applicant|
      if department_level?
        convocation_motifs.find { |motif| motif.organisation_id.in?(applicant.organisation_ids) }
      else
        convocation_motifs.first
      end
    end
  end

  def order_rdv_contexts
    @rdv_contexts = @rdv_contexts.order(created_at: :desc)
  end
end
