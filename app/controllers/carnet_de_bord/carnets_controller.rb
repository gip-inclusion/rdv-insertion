module CarnetDeBord
  class CarnetsController < ApplicationController
    before_action :set_user, :set_department

    # rubocop:disable Metrics/AbcSize
    def create
      @success, @errors = [create_carnet.success?, create_carnet.errors]
      if @success
        respond_to do |format|
          format.json { render json: { success: true, user: @user } }
          format.turbo_stream { flash.now[:success] = "Le carnet a été créé avec succès" }
        end
      else
        respond_to do |format|
          format.json { render json: { success: false, errors: @errors }, status: :unprocessable_entity }
          format.turbo_stream { flash.now[:error] = @errors.join(", ") }
        end
      end
    end
    # rubocop:enable Metrics/AbcSize

    private

    def carnet_params
      params.require(:carnet).permit(:user_id, :department_id)
    end

    def set_user
      @user = policy_scope(User).find(carnet_params[:user_id])
    end

    def set_department
      @department = policy_scope(Department).find(carnet_params[:department_id])
    end

    def create_carnet
      @create_carnet ||= CarnetDeBord::CreateCarnet.call(
        user: @user, agent: current_agent, department: @department
      )
    end
  end
end
