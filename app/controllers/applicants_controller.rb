# rubocop:disable Metrics/ClassLength

class ApplicantsController < ApplicationController
  PERMITTED_PARAMS = [
    :uid, :role, :first_name, :last_name, :birth_date, :email, :phone_number,
    :birth_name, :address, :affiliation_number, :department_internal_id, :title,
    :status, :rights_opening_date
  ].freeze

  include FilterableApplicantsConcern

  before_action :set_applicant, only: [:show, :update, :edit]
  before_action :set_organisation, :set_department, only: [:index, :new, :create, :show, :update, :edit]
  before_action :set_organisations, only: [:new, :index, :show, :create]
  before_action :set_motifs, only: [:index, :show]
  before_action :set_applicants_scope, :set_all_configurations, :set_current_configuration,
                :set_current_motif_category, :set_applicants, :set_rdv_contexts,
                :filter_applicants, :order_applicants, only: [:index]
  before_action :set_applicant_rdv_contexts, :set_can_be_added_to_other_org, only: [:show]
  before_action :retrieve_applicants, only: [:search]

  def new
    @applicant = Applicant.new(department: @department)
    authorize @applicant
  end

  def create
    @applicant = find_or_initialize_applicant.applicant
    # TODO: if an applicant exists, return it to the agent to let him decide what to do
    @applicant.assign_attributes(
      department: @department,
      **applicant_params.compact_blank
    )
    authorize @applicant
    respond_to do |format|
      format.html { save_applicant_and_redirect(:new) }
      format.json { save_applicant_and_render }
    end
  end

  def index
    respond_to do |format|
      format.html
      format.csv { send_applicants_csv }
    end
  end

  def show
    authorize @applicant
  end

  def search
    render json: { success: true, applicants: @applicants }
  end

  def edit
    authorize @applicant
  end

  def update
    @applicant.assign_attributes(**formatted_params)
    authorize @applicant
    respond_to do |format|
      format.html { save_applicant_and_redirect(:edit) }
      format.json { save_applicant_and_render }
    end
  end

  private

  def applicant_params
    params.require(:applicant).permit(*PERMITTED_PARAMS).to_h.deep_symbolize_keys
  end

  def formatted_params
    # we nullify some blank params for unicity exceptions (ActiveRecord::RecordNotUnique) not to raise
    applicant_params.to_h do |k, v|
      [k, k.in?([:affiliation_number, :department_internal_id, :email]) ? v.presence : v]
    end
  end

  def find_or_initialize_applicant
    @find_or_initialize_applicant ||= Applicants::FindOrInitialize.call(
      department_internal_id: applicant_params[:department_internal_id],
      role: applicant_params[:role],
      affiliation_number: applicant_params[:affiliation_number],
      department_id: @department.id
    )
  end

  def send_applicants_csv
    send_data generate_applicants_csv.csv, filename: generate_applicants_csv.filename
  end

  def generate_applicants_csv
    @generate_applicants_csv ||= Exporters::GenerateApplicantsCsv.call(
      applicants: @applicants,
      structure: department_level? ? @department : @organisation,
      motif_category: @current_motif_category
    )
  end

  def save_applicant_and_redirect(page)
    if save_applicant.success?
      redirect_to(after_save_path)
    else
      flash.now[:error] = save_applicant.errors&.join(',')
      render page, status: :unprocessable_entity
    end
  end

  def save_applicant_and_render
    if save_applicant.success?
      render json: { success: true, applicant: @applicant }
    else
      render json: { success: false, errors: save_applicant.errors }, status: :unprocessable_entity
    end
  end

  def save_applicant
    @save_applicant ||= Applicants::Save.call(
      applicant: @applicant,
      organisation: @organisation,
      rdv_solidarites_session: rdv_solidarites_session
    )
  end

  def set_applicant
    @applicant = \
      Applicant
      .includes(
        :organisations,
        rdv_contexts: [{ rdvs: [:organisation, :motif] }, :invitations],
        invitations: [:rdv_context]
      ).find(params[:id])
  end

  def set_organisation
    @organisation = \
      if department_level?
        set_organisation_at_department_level
      else
        policy_scope(Organisation).includes(:applicants, :configurations).find(params[:organisation_id])
      end
  end

  def set_organisation_at_department_level
    return set_organisation_through_form if params[:action] == "create"
    return if @applicant.nil? # no need to set an organisation if we are not in an applicant-level page

    @organisation = policy_scope(Organisation)
                    .find_by(id: @applicant.organisation_ids, department_id: params[:department_id])
  end

  def set_organisation_through_form
    # for now we allow only one organisation through creation
    @organisation = Organisation.find_by(
      id: params[:applicant][:organisation_ids], department_id: params[:department_id]
    )
  end

  def set_organisations
    return unless department_level?

    @organisations = policy_scope(Organisation).where(department: @department)
  end

  def set_department
    @department = \
      if department_level?
        policy_scope(Department).includes(:organisations, :applicants).find(params[:department_id])
      else
        @organisation.department
      end
  end

  def set_all_configurations
    @all_configurations = \
      if department_level?
        (policy_scope(::Configuration) & @department.configurations).uniq(&:motif_category).select do |config|
          motif_categories_from_motifs.include?(config.motif_category)
        end
      else
        @organisation.configurations.select do |config|
          motif_categories_from_motifs.include?(config.motif_category)
        end
      end
  end

  def set_current_configuration
    return if archived_scope?

    @current_configuration = \
      @all_configurations.find { |c| c.motif_category == params[:motif_category] } ||
      @all_configurations.first
  end

  def set_current_motif_category
    @current_motif_category = @current_configuration&.motif_category
  end

  def set_motifs
    @motifs = if department_level?
                Motif.where(organisation_id: @organisations.ids)
              else
                Motif.where(organisation_id: @organisation.id)
              end
  end

  def motif_categories_from_motifs
    @motif_categories_from_motifs ||= @motifs.map(&:category).uniq.compact
  end

  def motif_categories_from_configurations
    @motif_categories_from_configurations ||= if department_level?
                                                @organisations.flat_map(&:motif_categories).uniq
                                              else
                                                @organisation.motif_categories.uniq
                                              end
  end

  def set_applicant_rdv_contexts
    @rdv_contexts = @applicant.rdv_contexts.select do |rdv_context|
      (motif_categories_from_configurations & motif_categories_from_motifs).include?(rdv_context.motif_category)
    end
  end

  def set_can_be_added_to_other_org
    @can_be_added_to_other_org = (@department.organisation_ids - @applicant.organisation_ids).any?
  end

  def set_applicants
    archived_scope? ? set_archived_applicants : set_applicants_for_motif_category
  end

  def set_applicants_for_motif_category
    @applicants = policy_scope(Applicant)
                  .includes(:invitations, notifications: :rdv)
                  .preload(:organisations, rdv_contexts: [:invitations, :rdvs])
                  .active.distinct.archived(false)
                  .where(department_level? ? { department: @department } : { organisations: @organisation })
                  .joins(:rdv_contexts)
                  .where(rdv_contexts: { motif_category: @current_motif_category })
  end

  def set_archived_applicants
    @applicants = policy_scope(Applicant)
                  .active.distinct.archived
                  .where(department_level? ? { department: @department } : { organisations: @organisation })
  end

  def set_rdv_contexts
    return if archived_scope?

    @rdv_contexts = RdvContext.where(
      applicant_id: @applicants.ids, motif_category: @current_motif_category
    )
    @statuses_count = @rdv_contexts.group(:status).count
  end

  def set_applicants_scope
    @applicants_scope = params[:applicants_scope]
  end

  def archived_scope?
    @applicants_scope == "archived"
  end

  def order_applicants
    @applicants = if archived_scope?
                    @applicants.order(archived_at: :desc)
                  else
                    @applicants.order(created_at: :desc)
                  end
  end

  def after_save_path
    return department_applicant_path(@department, @applicant) if department_level?

    organisation_applicant_path(@organisation, @applicant)
  end

  def retrieve_applicants
    @applicants = policy_scope(Applicant).includes(:organisations, :rdvs, invitations: [:rdv_context]).distinct
    @applicants = @applicants
                  .where(department_internal_id: params.require(:applicants)[:department_internal_ids])
                  .or(@applicants.where(uid: params.require(:applicants)[:uids]))
                  .to_a
  end
end

# rubocop: enable Metrics/ClassLength
