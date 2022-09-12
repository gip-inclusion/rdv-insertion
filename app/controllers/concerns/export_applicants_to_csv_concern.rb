module ExportApplicantsToCsvConcern
  def export_applicants_to_csv
    csv = create_applicants_csv_export.csv
    filename = create_applicants_csv_export.filename
    send_data csv, filename: filename
  end

  def create_applicants_csv_export
    @structure = department_level? ? @department : @organisation
    GenerateApplicantsCsv.call(
      applicants: @applicants,
      structure: @structure,
      motif_category: @current_motif_category
    )
  end
end
