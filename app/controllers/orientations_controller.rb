class OrientationsController < ApplicationController
  before_action :set_user

  def new
    @orentation = Orientation.new(user: @user)
  end

  private

  def set_user
    @user = policy_scope(User).find(params[:user_id])
  end
end
