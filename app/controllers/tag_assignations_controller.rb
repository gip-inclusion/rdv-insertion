class TagAssignationsController < ApplicationController
  before_action :set_available_tags, only: [:index]
  before_action :set_user, only: [:index, :create, :destroy]
  before_action :set_tag, :set_user_tags, only: [:create, :destroy]

  def index; end

  def create
    @success = assign_tag.success?
    @errors = assign_tag.errors
    respond_to do |format|
      format.turbo_stream do
        set_user_tags
        set_available_tags
      end
      format.json do
        render json: { success: @success, errors: @errors }, status: @success ? :ok : :unprocessable_entity
      end
    end
  end

  def destroy
    remove_tag
    set_user_tags
    set_available_tags
  end

  private

  def set_user_tags
    @user_tags = @user
                 .tags
                 .joins(:organisations)
                 .where(organisations: department_level? ? department.organisations : organisation)
                 .order(:value)
                 .distinct
  end

  def set_available_tags
    @available_tags = department_level? ? department.tags : organisation.tags
  end

  def tag_assignation_params
    params.require(:tag_assignation).permit(:tag_id, :user_id)
  end

  def user_id
    params[:user_id] || tag_assignation_params[:user_id]
  end

  def set_user
    @user = policy_scope(User).includes(:referents).find(user_id)
  end

  def set_tag
    department_level? ? set_department_tag : set_organisation_tag
  end

  def set_department_tag
    @tag = department.tags.find(tag_assignation_params[:tag_id])
  end

  def set_organisation_tag
    @tag = organisation.tags.find(tag_assignation_params[:tag_id])
  end

  def department
    @department ||= policy_scope(Department).find(params[:department_id])
  end

  def organisation
    @organisation ||= policy_scope(Organisation).find(params[:organisation_id])
  end

  def assign_tag
    @assign_tag ||= Users::AssignTag.call(
      user: @user, tag: @tag
    )
  end

  def remove_tag
    @remove_tag ||= Users::RemoveTag.call(
      user: @user, tag: @tag
    )
  end
end
