class ArchivesController < ApplicationController
  before_action :set_user, :set_department, only: %i[new]

  def new
    @archive = Archive.new(user: @user, department: @department)
    authorize @archive
  end

  def create
    @archive = Archive.new(**archive_params)
    authorize @archive
    if @archive.save
      turbo_stream_redirect(structure_user_path(@archive.user.id))
    else
      turbo_stream_display_error_modal(@archive.errors.full_messages)
    end
  end

  def destroy
    @archive = Archive.find(params[:id])
    authorize @archive
    if @archive.destroy
      render json: { success: true, archive: @archive, redirect_path: structure_user_path(@archive.user_id) }
    else
      render json: { success: false, errors: @archive.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = policy_scope(User).find(params[:user_id])
  end

  def set_department
    @department = policy_scope(Department).find(current_department_id)
  end

  def archive_params
    params.require(:archive).permit(:archiving_reason, :user_id, :department_id).to_h.symbolize_keys
  end
end
