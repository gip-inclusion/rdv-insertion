class ArchivingsController < ApplicationController
  def create
    @archiving = Archiving.new(**archiving_params)
    authorize @archiving
    if @archiving.save
      render json: { success: true, archiving: @archiving }
    else
      render json: { success: false, errors: @archiving.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @archiving = Archiving.find(params[:id])
    authorize @archiving
    if @archiving.destroy
      render json: { success: true, archiving: @archiving }
    else
      render json: { success: false, errors: @archiving.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def archiving_params
    params.require(:archiving).permit(:archiving_reason, :applicant_id, :department_id).to_h.symbolize_keys
  end
end
