class ArchivesController < ApplicationController
  before_action :set_user, only: [:new, :new_batch]
  before_action :set_organisation, only: [:new]
  before_action :set_department, :set_user_archives, :set_archivable_organisations, only: [:new_batch]

  def new; end

  def new_batch; end

  def create
    @archive = Archive.new(**archive_params)
    authorize @archive
    if @archive.save
      flash_success_for_create(@archive)
      redirect_to structure_user_path(@archive.user_id)
    else
      turbo_stream_display_error_modal(@archive.errors.full_messages)
    end
  end

  def create_many
    @archives = Archive.new_batch(**create_many_params)
    authorize_all @archives, :create
    Archive.transaction { @archives.each(&:save!) }

    flash_success_for_create_many(@archives)
    redirect_to structure_user_path(params[:user_id])
  rescue ActiveRecord::RecordInvalid => e
    turbo_stream_display_error_modal(e.record.errors.full_messages)
  end

  def destroy # rubocop:disable Metrics/AbcSize
    @archive = Archive.find(params[:id])
    authorize @archive
    respond_to do |format|
      if @archive.destroy
        flash_success_for_destroy
        format.turbo_stream { turbo_stream_redirect(structure_user_path(@archive.user_id)) }
        format.json { render json: { success: true, archive: @archive, redirect_path: request.referer } }
      else
        format.html { turbo_stream_display_error_modal(@archive.errors.full_messages) }
        format.json do
          render json: { success: false, errors: @archive.errors.full_messages }, status: :unprocessable_entity
        end
      end
    end
  end

  private

  def archive_params
    params.expect(archive: [:archiving_reason, :user_id, :organisation_id]).to_h.deep_symbolize_keys
  end

  def create_many_params
    params.expect(archives: [:user_id, :archiving_reason, { organisation_ids: [] }]).to_h.deep_symbolize_keys
  end

  def set_user
    @user = policy_scope(User).find(params[:user_id])
  end

  def set_organisation
    @organisation = policy_scope(Organisation).find(current_organisation_id)
  end

  def set_department
    @department = policy_scope(Department).find(current_department_id)
  end

  def set_user_archives
    @user_archives = @user.archives
  end

  def set_archivable_organisations
    @archivable_organisations = user_department_organisations - @user_archives.map(&:organisation)
  end

  def user_department_organisations
    policy_scope(Organisation).where(id: @user.organisation_ids, department: @department)
  end

  # rubocop:disable Rails/ActionControllerFlashBeforeRender
  def flash_success_for_create(archive)
    flash[:success] = {
      title: "Dossier archivé",
      description: "L'usager a bien été archivé sur l'organisation #{archive.organisation.name}"
    }
  end

  def flash_success_for_create_many(archives)
    archived_organisations = archives.map(&:organisation)
    archived_organisations_names = archived_organisations.map(&:name).join(", ")
    organisation_count = archived_organisations.size
    organisation_wording = organisation_count > 1 ? "les organisations" : "l'organisation"

    flash[:success] = {
      title: "Dossier archivé",
      description: "L'usager a bien été archivé sur #{organisation_wording} #{archived_organisations_names}"
    }
  end

  def flash_success_for_destroy
    flash[:success] = {
      title: "Dossier désarchivé",
      description: "Le dossier de l'usager a bien été rouvert sur cette organisation"
    }
  end
  # rubocop:enable Rails/ActionControllerFlashBeforeRender
end
