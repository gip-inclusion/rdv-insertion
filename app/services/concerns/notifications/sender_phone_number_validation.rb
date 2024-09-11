module Notifications
  module SenderPhoneNumberValidation
    def verify_sender_phone_number!(notification)
      return if notification.rdv.phone_number.present?

      fail!("Le numéro de téléphone de l'organisation, du lieu ou de la catégorie doit être renseigné")
      MattermostClient.send_to_private_channel(
        "Une convocation a été envoyée par l'organisation #{notification.organisation.name} sans numéro de téléphone " \
        "de l'organisation, du lieu ou de la catégorie pour le rendez-vous" \
        " avec l'ID #{notification.rdv.id} et l'usager avec l'ID #{notification.participation.user.id}."
      )
    end
  end
end
