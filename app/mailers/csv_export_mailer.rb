class CsvExportMailer < ApplicationMailer
  def users_csv_export(email, export)
    @export = export
    mail(to: email, subject: "[RDV-Insertion] Export CSV des usagers")
  end
end
