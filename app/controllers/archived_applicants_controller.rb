class ArchivedApplicantsController < ApplicationController
  before_action :set_organisation, :set_department, :set_all_configurations, :set_current_configuration,
                :set_current_motif_category, :set_applicants, :set_rdv_contexts, only: [:index]

  include FilterableApplicantsConcern
  include ApplicantsVariablesConcern
  include ExportApplicantsToCsvConcern

  def index
    filter_applicants
    @applicants = @applicants.order(created_at: :desc)
    respond_to do |format|
      format.html { render "applicants/index" }
      format.csv { export_applicants_to_csv }
    end
  end

  private

  def set_current_configuration
    @current_configuration = nil
  end

  def set_current_motif_category
    @current_motif_category = nil
  end

  def set_applicants
    @applicants = policy_scope(Applicant)
                  .includes(:invitations)
                  .preload(:organisations, rdv_contexts: [:invitations, :rdvs])
                  .archived(true)
                  .active.distinct
    @applicants = \
      if department_level?
        @applicants.where(department: @department)
      else
        @applicants.where(organisations: @organisation)
      end
  end

  def set_rdv_contexts
    @rdv_contexts = RdvContext.where(applicant_id: @applicants.ids)
    @statuses_count = @rdv_contexts.group(:status).count
  end
end
