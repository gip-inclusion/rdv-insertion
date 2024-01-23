class CsvExportMailer < ApplicationMailer
  def users_csv_export(email, file)
    send_csv("[RDV-Insertion] Export CSV des usagers", email, file)
  end

  def users_participations_csv_export(email, file)
    send_csv("[RDV-Insertion] Export CSV des rendez-vous des usagers", email, file)
  end

  private

  def send_csv(subject, email, file)
    attachments[file.filename] = { mime_type: file.mime_type, content: file.read }
    mail(to: email, subject:)
  rescue StandardError => e
    body = "Une erreur est survenue lors de la création de l'export CSV que vous avez demandé. \n" \
           "Veuillez réessayer ou nous contacter à l'adresse rdv-insertion@beta.gouv.fr.  \n" \
           "Merci de nous excuser pour la gêne occasionnée.  \n" \
           "L'équipe RDV-Insertion"

    mail(to: email, subject:, body:)
    Sentry.capture_message("Error when sending CSV export: #{e.message}")
  end
end
