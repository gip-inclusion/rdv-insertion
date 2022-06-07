module Invitations
  class SendSms < BaseService
    include Rails.application.routes.url_helpers

    def initialize(invitation:)
      @invitation = invitation
    end

    def call
      check_invitation_format!
      check_phone_number!
      send_sms
    end

    private

    def check_invitation_format!
      fail!("Envoi de SMS alors que le format est #{@invitation.format}") unless @invitation.format_sms?
    end

    def check_phone_number!
      fail!("Le téléphone doit être renseigné") if applicant.phone_number.blank?
      fail!("Le numéro de téléphone doit être un mobile") unless applicant.phone_number_is_mobile?
    end

    def send_sms
      return Rails.logger.info(content) unless Rails.env.production?

      SendTransactionalSms.call(phone_number_formatted: phone_number_formatted,
                                sender_name: sender_name, content: content)
    end

    def content
      send(:"content_for_#{@invitation.context}")
    end

    def content_for_rsa_orientation
      "#{applicant.full_name},\nVous êtes bénéficiaire du RSA et vous devez vous présenter à un rendez-vous " \
        "d'orientation. Pour choisir la date et l'horaire de votre premier RDV, " \
        "cliquez sur le lien suivant dans les #{number_of_days_to_accept_invitation} jours: " \
        "#{redirect_invitations_url(params: { token: @invitation.token }, host: ENV['HOST'])}\n" \
        "Ce rendez-vous est obligatoire. En cas de problème technique, contactez le "\
        "#{@invitation.help_phone_number}."
    end

    def content_for_rsa_accompagnement
      "#{applicant.full_name},\nVous êtes bénéficiaire du RSA et vous devez vous présenter à un rendez-vous " \
        "d'accompagnement. Pour choisir la date et l'horaire de votre premier RDV, " \
        "cliquez sur le lien suivant dans les #{number_of_days_to_accept_invitation} jours: " \
        "#{redirect_invitations_url(params: { token: @invitation.token }, host: ENV['HOST'])}\n" \
        "Ce rendez-vous est obligatoire. En l’absence d'action de votre part, " \
        "le versement de votre RSA pourra être suspendu. En cas de problème technique, contactez le "\
        "#{@invitation.help_phone_number}."
    end

    def content_for_rsa_orientation_on_phone_platform
      "#{applicant.full_name},\nVous êtes bénéficiaire du RSA et vous devez contacter la plateforme départementale " \
        "afin de démarrer votre parcours d’accompagnement. Pour cela, merci d’appeler le " \
        "#{@invitation.help_phone_number} dans un délai de #{number_of_days_to_accept_invitation} jours. "\
        "Cet appel est nécessaire pour le traitement de votre dossier."
    end

    def phone_number_formatted
      applicant.phone_number_formatted
    end

    def number_of_days_to_accept_invitation
      @invitation.number_of_days_to_accept_invitation
    end

    def sender_name
      @invitation.invitation_parameters&.sms_sender_name || "Dept#{@invitation.department.number}"
    end

    def applicant
      @invitation.applicant
    end

    def configuration
      organisation.configurations.find_by(context: @invitation.context)
    end

    def organisation
      @invitation.organisations.first
    end
  end
end
