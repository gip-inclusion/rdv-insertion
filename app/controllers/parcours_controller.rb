class ParcoursController < ApplicationController
  before_action :set_user

  def index
    authorize(current_department)
  end

  private

  def set_user
    @user = policy_scope(User).find(params[:user_id])
  end
end
