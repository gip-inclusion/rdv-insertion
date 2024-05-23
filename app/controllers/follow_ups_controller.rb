class FollowUpsController < ApplicationController
  PERMITTED_PARAMS = [:user_id, :motif_category_id].freeze

  before_action :set_user, only: [:create]

  def create
    @follow_up = FollowUp.new(**follow_up_params)
    authorize @follow_up
    if save_follow_up.success?
      redirect_to request.referer
    else
      turbo_stream_display_error_modal(save_follow_up.errors)
    end
  end

  private

  def follow_up_params
    params.require(:follow_up).permit(*PERMITTED_PARAMS).to_h.deep_symbolize_keys
  end

  def set_user
    @user = policy_scope(User).preload(:archives).find(follow_up_params[:user_id])
  end

  def save_follow_up
    @save_follow_up ||= FollowUps::Save.call(follow_up: @follow_up)
  end
end
