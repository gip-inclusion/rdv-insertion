class CsvExportMailer < ApplicationMailer
  def applicants_csv_export(csv, email, structure)
    csv_name_with_structure = "#{structure.class.name}_#{structure.class.name}_applicants_extraction.csv"
    csv_name = structure.nil? ? "applicants_extraction.csv" : csv_name_with_structure
    attachments[csv_name] = { mime_type: 'text/csv', content: csv }
    mail(
      to: email,
      subject: "Export csv d'allocataires",
      body: ""
    )
  end
end
