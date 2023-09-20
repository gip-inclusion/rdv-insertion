class CsvExportMailer < ApplicationMailer
  def users_csv_export(email, csv, filename)
    attachments[filename] = { mime_type: "text/csv", content: csv }
    mail(
      to: email,
      subject: "Export csv d'usagers",
      body: ""
    )
  end
end
