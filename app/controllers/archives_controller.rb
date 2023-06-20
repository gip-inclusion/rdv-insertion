class ArchivesController < ApplicationController
  include SetOrganisationAndDepartmentConcern
  include SetAllConfigurationsConcern
  include SetCurrentAgentRolesConcern
  include BackToListConcern
  include Archives::Filterable
  include ExtractableConcern

  before_action :set_organisation, :set_department, :set_organisations, :set_all_configurations,
                :set_current_agent_roles, :set_applicants, :set_archives, :filter_archives, :order_archives,
                :store_back_to_list_url, :set_back_to_list_url, :set_extraction_url,
                for: :index

  def index
    respond_to do |format|
      format.html
      format.csv { send_csv }
    end
  end

  def create
    @archive = Archive.new(**archive_params)
    authorize @archive
    if @archive.save
      render json: { success: true, archive: @archive }
    else
      render json: { success: false, errors: @archive.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @archive = Archive.find(params[:id])
    authorize @archive
    if @archive.destroy
      render json: { success: true, archive: @archive }
    else
      render json: { success: false, errors: @archive.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def archive_params
    params.require(:archive).permit(:archiving_reason, :applicant_id, :department_id).to_h.symbolize_keys
  end

  def set_archives
    @archives = Archive.where(applicant: @applicants).where(department: @department).distinct
  end

  def set_applicants
    @applicants = policy_scope(Applicant)
                  .active
                  .where(department_level? ? { organisations: @organisations } : { organisations: @organisation })
  end

  def order_archives
    @archives = @archives.order(created_at: :desc)
  end
end
