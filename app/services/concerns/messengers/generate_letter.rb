module Messengers::GenerateLetter
  extend ActiveSupport::Concern

  included do
    before_call :verify_invitation_format!, :verify_address!, :verify_direction_names!
  end

  def verify_invitation_format!
    fail!("Génération d'une lettre alors que le format est #{sendable.format}") unless sendable.format_postal?
  end

  def verify_address!
    fail!("L'adresse doit être renseignée") if sendable.address.blank?
    fail!("Le format de l'adresse est invalide") \
      if sendable.street_address.blank? || sendable.zipcode_and_city.blank?
  end

  def verify_direction_names!
    return if sendable.direction_names.present?

    fail!("La configuration des courriers pour votre organisation est incomplète")
  end

  def sendable
    raise NotImplementedError
  end
end
