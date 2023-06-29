module CarnetDeBord
  class CarnetsController < ApplicationController
    before_action :set_applicant, :set_department

    def create
      @success, @errors = [create_carnet.success?, create_carnet.errors]
      if @success
        respond_to do |format|
          format.json { render json: { success: true, applicant: @applicant } }
          format.turbo_stream { flash.now[:success] = "Le carnet a été créé avec succès" }
        end
      else
        respond_to do |format|
          format.json { render json: { success: false, errors: @errors }, status: :unprocessable_entity }
          format.turbo_stream { flash.now[:error] = @errors }
        end
      end
    end

    private

    def carnet_params
      params.require(:carnet).permit(:applicant_id, :department_id)
    end

    def set_applicant
      @applicant = policy_scope(Applicant).find(carnet_params[:applicant_id])
    end

    def set_department
      @department = policy_scope(Department).find(carnet_params[:department_id])
    end

    def create_carnet
      @create_carnet ||= CarnetDeBord::CreateCarnet.call(
        applicant: @applicant, agent: current_agent, department: @department
      )
    end
  end
end
