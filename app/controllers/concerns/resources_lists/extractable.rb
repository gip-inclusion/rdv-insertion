module ResourcesLists::Extractable
  private

  def send_csv
    send_data generate_csv.csv, filename: generate_csv.filename
  end

  def generate_csv
    @generate_csv ||= Exporters::GenerateApplicantsCsv.call(
      applicants: csv_applicants,
      structure: department_level? ? @department : @organisation,
      motif_category: @current_motif_category
    )
  end

  def csv_applicants
    @csv_applicants ||= case controller_name
                        when "applicants"
                          @applicants
                        when "rdv_contexts"
                          @applicants.where(id: @rdv_contexts.map(&:applicant_id))
                        when "archives"
                          @applicants.where(id: @archives.map(&:applicant_id))
                        end
  end

  def set_extraction_url
    @extraction_url = "#{request.path}?#{params.except(:action, :controller).to_unsafe_h.merge(format: :csv).to_query}"
  end
end
