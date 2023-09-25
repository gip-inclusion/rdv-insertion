class ArchivesController < ApplicationController
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
    params.require(:archive).permit(:archiving_reason, :user_id, :department_id).to_h.symbolize_keys
  end
end
