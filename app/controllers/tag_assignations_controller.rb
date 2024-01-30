class TagAssignationsController < ApplicationController
  before_action :set_available_tags, :set_user

  def index; end

  def create
    @user.tags << tag
    set_user_tags
  end

  def destroy
    @user.tags.delete(tag)
    set_user_tags
  end

  private

  def set_available_tags
    @available_tags = department_level? ? department.tags.uniq : organisation.tags
  end

  def set_user
    @user = policy_scope(User).includes(:tags).find(params[:user_id] || tag_assignation_params[:user_id])
  end

  def set_user_tags
    @user_tags = @user
                 .tags
                 .joins(:organisations)
                 .where(organisations: department_level? ? department.organisations : organisation)
                 .order(:value)
                 .distinct
  end

  def tag_assignation_params
    params.require(:tag_assignation).permit(:tag_id, :user_id)
  end

  def department
    @department ||= policy_scope(Department).find(params[:department_id])
  end

  def organisation
    @organisation ||= policy_scope(Organisation).find(params[:organisation_id])
  end

  def tag
    @available_tags.find(tag_assignation_params[:tag_id])
  end
end
