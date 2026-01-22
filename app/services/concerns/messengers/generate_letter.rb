module Messengers::GenerateLetter
  private

  def verify_format!(sendable)
    fail!("Génération d'une lettre alors que le format est #{sendable.format}") unless sendable.format_postal?
  end

  def verify_address!(sendable)
    fail!("L'adresse doit être renseignée") if sendable.address.blank?
    fail!("Le format de l'adresse est invalide. Le format attendu est le suivant: 10 rue de l'envoi 12345 - La Ville") \
      if sendable.parsed_street_address.blank? || sendable.parsed_post_code_and_city.blank?
  end

  def generate_pdf(sendable:, content:)
    pdf_result = PdfGeneration::Generate.call(
      content: content,
      context: { "#{sendable.model_name.singular}_id" => sendable.id }
    )

    if pdf_result.success?
      sendable.pdf_data = pdf_result.pdf_data
    else
      result.error_type = pdf_result.error_type
      fail!(pdf_result.errors.first)
    end
  end
end
