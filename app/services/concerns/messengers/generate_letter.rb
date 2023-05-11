module Messengers::GenerateLetter
  private

  def verify_format!(sendable)
    fail!("Génération d'une lettre alors que le format est #{sendable.format}") unless sendable.format_postal?
  end

  def verify_address!(sendable)
    fail!("L'adresse doit être renseignée") if sendable.address.blank?
    fail!("Le format de l'adresse est invalide. Le format attendu est le suivant: 10 rue de l'envoi 12345 - La Ville") \
      if sendable.street_address.blank? || sendable.zipcode_and_city.blank?
  end
end
