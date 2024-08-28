module Notifications
  module SenderPhoneNumberValidation
    def verify_sender_phone_number!(sender_phone_number)
      return if sender_phone_number.present?

      fail!("Le numéro de téléphone de l'organisation, du lieu ou de la catégorie doit être renseigné")
    end
  end
end
