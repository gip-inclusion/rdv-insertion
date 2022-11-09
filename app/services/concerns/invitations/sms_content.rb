module Invitations
  module SmsContent
    extend ActiveSupport::Concern

    include Rails.application.routes.url_helpers
    include Templatable

    private

    def regular_invitation_content
      "#{applicant.full_name},\nVous êtes bénéficiaire du RSA et vous devez vous présenter à un #{rdv_title} " \
        "afin de #{rdv_purpose}. Pour choisir la date et l'horaire du RDV, " \
        "cliquez sur le lien suivant dans les #{number_of_days_to_accept_invitation} jours: " \
        "#{redirect_invitations_url(params: { uuid: @invitation.uuid }, host: ENV['HOST'])}\n" \
        "#{mandatory_warning}"\
        "#{punishable_warning}" \
        "En cas de problème technique, contactez le #{help_phone_number}."
    end

    def content_for_rsa_orientation_on_phone_platform
      "#{applicant.full_name},\nVous êtes bénéficiaire du RSA et vous devez contacter la plateforme départementale " \
        "afin de démarrer votre parcours d'accompagnement. Pour cela, merci d'appeler le " \
        "#{help_phone_number} dans un délai de #{number_of_days_to_accept_invitation} jours. "\
        "Cet appel est nécessaire pour le traitement de votre dossier."
    end

    def content_for_rsa_insertion_offer
      "#{applicant.full_name},\nVous êtes bénéficiaire du RSA et bénéficiez d'un accompagnement en parcours "\
        "professionnel ou socio-professionel. Pour profiter au mieux de cet accompagnement, nous vous invitons "\
        "à vous inscrire directement et librement aux ateliers et formations de votre choix en cliquant sur le lien " \
        "suivant: #{redirect_invitations_url(params: { uuid: @invitation.uuid }, host: ENV['HOST'])}\n" \
        "En cas de problème technique, contactez le #{help_phone_number}."
    end

    ### Reminders

    def regular_invitation_reminder_content
      "#{applicant.full_name},\nEn tant que bénéficiaire du RSA, vous avez reçu un message il y a 3 jours " \
        "vous invitant à prendre RDV au créneau de votre choix afin de #{rdv_purpose}." \
        " Le lien de prise de RDV suivant expire dans #{number_of_days_before_expiration} " \
        "jours: " \
        "#{redirect_invitations_url(params: { uuid: @invitation.uuid }, host: ENV['HOST'])}\n" \
        "#{mandatory_warning}"\
        "#{punishable_warning}"\
        "En cas de problème technique, contactez le #{help_phone_number}."
    end

    def content_for_rsa_orientation_on_phone_platform_reminder
      "#{applicant.full_name},\nEn tant que bénéficiaire du RSA, vous avez reçu un message il y a 3 jours vous " \
        "invitant à contacter la plateforme départementale afin de démarrer un parcours d'accompagnement. " \
        "Vous n'avez plus que #{number_of_days_before_expiration} jours pour appeler le " \
        "#{help_phone_number}. Cet appel est obligatoire pour le traitement de votre dossier."
    end

    ###

    def mandatory_warning
      display_mandatory_warning ? 'Ce rendez-vous est obligatoire. ' : ''
    end

    def punishable_warning
      if display_punishable_warning
        "En l'absence d'action de votre part, le versement de votre RSA pourra être suspendu ou réduit. "
      else
        ''
      end
    end
  end
end
