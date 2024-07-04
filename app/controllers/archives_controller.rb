class ArchivesController < ApplicationController
  before_action :set_user, :set_organisation, only: %i[new create]
  before_action :set_department, :set_user_archives, :set_archivable_organisations,
                only: %i[new], if: -> { department_level? }

  def new
    @archive = Archive.new(user: @user, organisation: @organisation)
    authorize @archive
  end

  def create
    @archive = Archive.new(archive_params.merge(user: @user, organisation: @organisation))
    authorize @archive
    if @archive.save
      redirect_to structure_user_path(@archive.user_id)
    else
      turbo_stream_display_error_modal(@archive.errors.full_messages)
    end
  end

  def create_many
    if create_archives.success?
      redirect_to structure_user_path(params[:user_id])
    else
      turbo_stream_display_error_modal(create_archives.errors)
    end
  end

  def destroy # rubocop:disable Metrics/AbcSize
    @archive = Archive.find(params[:id])
    authorize @archive
    respond_to do |format|
      if @archive.destroy
        format.html { redirect_to structure_user_path(@archive.user_id) }
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
    params.require(:archive).permit(:archiving_reason)
  end

  def create_many_archives_params
    params.require(:archives).permit(:user_id, :archiving_reason, organisation_ids: [])
  end

  def create_archives
    @create_archives ||= Archives::CreateMany.call(
      user_id: create_many_archives_params[:user_id],
      archiving_reason: create_many_archives_params[:archiving_reason],
      organisation_ids: create_many_archives_params[:organisation_ids]
    )
  end

  def set_user
    @user = policy_scope(User).preload(archives: [:organisation]).find(params[:user_id])
  end

  def set_organisation
    @organisation =
      if department_level?
        (@user.organisations & current_agent_department_organisations).first
      else
        policy_scope(Organisation).find(current_organisation_id)
      end
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
end
