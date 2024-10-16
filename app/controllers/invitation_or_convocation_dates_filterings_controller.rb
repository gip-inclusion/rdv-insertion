class InvitationOrConvocationDatesFilteringsController < ApplicationController
  def new
    return if params[:invitation_type].blank?

    render turbo_stream: turbo_stream.replace("remote_modal", partial: "new_#{params[:invitation_type]}")
  end
end
