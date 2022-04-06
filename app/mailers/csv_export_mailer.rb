class CsvExportMailer < ApplicationMailer
  def applicants_csv_export(csv, email)
    attachments["applicants_extraction.csv"] = { mime_type: 'text/csv', content: csv }
    mail(
      to: email,
      subject: "Export csv des allocataires",
      body: ""
    )
  end
end
