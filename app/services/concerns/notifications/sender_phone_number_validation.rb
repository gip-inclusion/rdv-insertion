module Notifications
  module SenderPhoneNumberValidation
    def verify_sender_phone_number!(notification)
      return if notification.rdv.phone_number.present?

      SlackClient.send_unique_message(
        channel_type: :private,
        text: "Un rendez-vous de convocation (#{notification.rdv.id}) a été placé pour cet usager" \
              " (#{notification.participation.user.id}) mais la convocation n'a pas été envoyée car l'organisation" \
              " #{notification.organisation.name} n'a pas de numéro de téléphone."
      )

      fail!("Le numéro de téléphone de l'organisation, du lieu ou de la catégorie doit être renseigné")
    end
  end
end
