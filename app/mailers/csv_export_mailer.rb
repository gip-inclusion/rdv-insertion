class CsvExportMailer < ApplicationMailer
  def applicants_csv_export(csv, email, structure)
    csv_name = if structure.nil?
                 "applicants_extraction.csv"
               else
                 "#{structure.class.name}_#{structure.name}_applicants_extraction.csv"
               end
    attachments[csv_name] = { mime_type: 'text/csv', content: csv }
    mail(
      to: email,
      subject: "Export csv d'allocataires",
      body: ""
    )
  end
end
