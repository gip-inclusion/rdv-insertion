module Users
  class ParcoursController < ApplicationController
    before_action :set_user, :set_department, only: :show

    def show
      # @orientations = @user.orientations
    end

    private

    def set_department
      @department = policy_scope(Department).find(current_department_id)
    end

    def set_user
      @user = policy_scope(User).find(params[:user_id])
    end
  end
end
