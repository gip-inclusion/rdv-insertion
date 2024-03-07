class UploadedLogosController < ApplicationController
  # Needed to generate ActiveStorage urls locally, it sets the host and protocol
  include ActiveStorage::SetCurrent

  def show
    blob = ActiveStorage::Blob.find(params[:id])
    redirect_to blob.url, allow_other_host: true
  end
end
