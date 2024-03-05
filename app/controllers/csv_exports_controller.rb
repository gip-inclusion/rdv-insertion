class CsvExportsController < ApplicationController
  # Needed to generate ActiveStorage urls locally, it sets the host and protocol
  include ActiveStorage::SetCurrent

  def show
    @csv_export = CsvExport.find(params[:id])
    authorize @csv_export

    if @csv_export.expired?
      flash[:alert] = "Ce fichier CSV a expiré"
      redirect_to root_path
    else
      redirect_to @csv_export.file.url, allow_other_host: true
    end
  end
end
