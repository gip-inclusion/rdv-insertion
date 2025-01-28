class FollowUpsController < ApplicationController
  def create
    @follow_up = FollowUp.new(follow_up_params)
    authorize @follow_up
    if save_follow_up.success?
      redirect_to request.referer
    else
      turbo_stream_display_error_modal(save_follow_up.errors)
    end
  end

  private

  def follow_up_params
    params.expect(follow_up: [:user_id, :motif_category_id])
  end

  def save_follow_up
    @save_follow_up ||= FollowUps::Save.call(follow_up: @follow_up)
  end
end
