class CsvExportMailer < ApplicationMailer
  def users_csv_export(email, csv, filename)
    send_csv("[RDV-Insertion] Export CSV des usagers", email, csv, filename)
  end

  def users_participations_csv_export(email, csv, filename)
    send_csv("[RDV-Insertion] Export CSV des rendez-vous", email, csv, filename)
  end

  private

  def send_csv(subject, email, csv, filename)
    CompressFile.new(csv, filename).call do |zip|
      attachments[filename] = { mime_type: zip.mime_type, content: zip.read }
      mail(to: email, subject:)
    end
  rescue StandardError => e
    body = "Une erreur est survenue lors de la création de l'export CSV que vous avez demandé. \n" \
           "Veuillez réessayer ou nous contacter à l'adresse data.insertion@beta.gouv.fr.  \n" \
           "Merci de nous excuser pour la gêne occasionnée.  \n" \
           "L'équipe RDV-Insertion"

    mail(to: email, subject:, body:)
    raise e
  end
end
