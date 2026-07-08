class PostRdvOrientationsController < ApplicationController
  def create
    @post_rdv_orientation = PostRdvOrientation.new(post_rdv_orientation_params)
    authorize @post_rdv_orientation
    if @post_rdv_orientation.save
      turbo_stream_redirect structure_user_follow_ups_path(
        user_id: @post_rdv_orientation.participation.user_id
      )
    else
      turbo_stream_replace_error_list_with(@post_rdv_orientation.errors.full_messages)
    end
  end

  private

  def post_rdv_orientation_params
    params.expect(post_rdv_orientation: [:participation_id, :orientation_type_id])
  end
end
