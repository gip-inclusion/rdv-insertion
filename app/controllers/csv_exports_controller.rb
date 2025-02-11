class CsvExportsController < ApplicationController
  def show
    csv_export = CsvExport.find_signed(params[:id].to_s)
    authorize csv_export

    if csv_export.expired?
      flash[:alert] = "Ce fichier CSV a expiré"
      redirect_to root_path
    else
      redirect_to csv_export.file.url, allow_other_host: true
    end
  end
end
