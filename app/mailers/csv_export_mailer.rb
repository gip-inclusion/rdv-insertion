class CsvExportMailer < ApplicationMailer
  def notify_csv_export(email, export)
    @export = export
    mail(to: email, subject: "[RDV-Insertion] Voici l'export CSV que vous avez demandé")
  end
end
