class UploadedLogosController < ApplicationController
  # Needed to generate ActiveStorage urls locally, it sets the host and protocol
  include ActiveStorage::SetCurrent
  # logos are public and can be displayed on pages like teleprocedure landing
  skip_before_action :authenticate_agent!

  def show
    blob = ActiveStorage::Blob.find_signed(params[:signed_id])
    # this route can be theorically used to access any blob, so we need to ensure the blob is a logo
    authorize blob
    redirect_to blob.url, allow_other_host: true
  end
end
