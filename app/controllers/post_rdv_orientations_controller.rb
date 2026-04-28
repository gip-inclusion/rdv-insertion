class PostRdvOrientationsController < ApplicationController
  def create
    @post_rdv_orientation = PostRdvOrientation.new(post_rdv_orientation_params)
    authorize @post_rdv_orientation
    if @post_rdv_orientation.save
      redirect_to structure_user_follow_ups_path(
        user_id: @post_rdv_orientation.participation.user_id,
        tally_form_id: ENV["POST_RDV_ORIENTATION_TALLY_ID"]
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
