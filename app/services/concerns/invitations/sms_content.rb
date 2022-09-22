module Invitations
  module SmsContent
    extend ActiveSupport::Concern

    def content_for_rsa_orientation
      "#{applicant.full_name},\nVous êtes bénéficiaire du RSA et vous devez vous présenter à un rendez-vous " \
        "d'orientation. Pour choisir la date et l'horaire de votre premier RDV, " \
        "cliquez sur le lien suivant dans les #{number_of_days_to_accept_invitation} jours: " \
        "#{redirect_invitations_url(params: { uuid: @invitation.uuid }, host: ENV['HOST'])}\n" \
        "Ce rendez-vous est obligatoire. En cas de problème technique, contactez le "\
        "#{@invitation.help_phone_number}."
    end

    def content_for_rsa_accompagnement
      "#{applicant.full_name},\nVous êtes bénéficiaire du RSA et vous devez vous présenter à un rendez-vous " \
        "d'accompagnement. Pour choisir la date et l'horaire de votre premier RDV, " \
        "cliquez sur le lien suivant dans les #{number_of_days_to_accept_invitation} jours: " \
        "#{redirect_invitations_url(params: { uuid: @invitation.uuid }, host: ENV['HOST'])}\n" \
        "Ce rendez-vous est obligatoire. En l’absence d'action de votre part, " \
        "le versement de votre RSA pourra être suspendu ou réduit. En cas de problème technique, contactez le "\
        "#{@invitation.help_phone_number}."
    end

    def content_for_rsa_orientation_on_phone_platform
      "#{applicant.full_name},\nVous êtes bénéficiaire du RSA et vous devez contacter la plateforme départementale " \
        "afin de démarrer votre parcours d’accompagnement. Pour cela, merci d’appeler le " \
        "#{@invitation.help_phone_number} dans un délai de #{number_of_days_to_accept_invitation} jours. "\
        "Cet appel est nécessaire pour le traitement de votre dossier."
    end

    def content_for_rsa_cer_signature
      "#{applicant.full_name},\nVous êtes bénéficiaire du RSA, et à ce titre vous allez construire et signer "\
        "votre Contrat d'Engagement Réciproque. Pour cela, nous vous invitons à prendre RDV avec votre référent de " \
        "parcours. Pour choisir la date et l'horaire du RDV, cliquez sur le lien suivant dans un délai de " \
        "#{number_of_days_to_accept_invitation} jours: " \
        "#{redirect_invitations_url(params: { uuid: @invitation.uuid }, host: ENV['HOST'])}\n."\
        "En l'absence d'action de votre part, le versement de votre RSA pourra être suspendu ou réduit. "\
        "En cas de problème technique, contactez le #{@invitation.help_phone_number}."
    end

    ### Reminders

    def content_for_rsa_orientation_reminder
      "#{applicant.full_name},\nEn tant que bénéficiaire du RSA, vous avez reçu un message il y a 3 jours " \
        "vous invitant à prendre RDV au créneau de votre choix afin de démarrer un parcours d’accompagnement." \
        " Le lien de prise de RDV suivant expire dans #{@invitation.number_of_days_before_expiration} "\
        "jours: " \
        "#{redirect_invitations_url(params: { uuid: @invitation.uuid }, host: ENV['HOST'])}\n" \
        "Ce rendez-vous est obligatoire. En cas de problème technique, contactez le "\
        "#{@invitation.help_phone_number}."
    end

    def content_for_rsa_accompagnement_reminder
      "#{applicant.full_name},\nEn tant que bénéficiaire du RSA, vous avez reçu un message il y a 3 jours " \
        "vous invitant à prendre RDV au créneau de votre choix afin de démarrer un parcours d’accompagnement." \
        " Le lien de prise de RDV suivant expire dans #{@invitation.number_of_days_before_expiration} " \
        "jours: " \
        "#{redirect_invitations_url(params: { uuid: @invitation.uuid }, host: ENV['HOST'])}\n" \
        "Ce rendez-vous est obligatoire. En l’absence d'action de votre part, " \
        "le versement de votre RSA pourra être suspendu ou réduit. En cas de problème technique, contactez le "\
        "#{@invitation.help_phone_number}."
    end

    def content_for_rsa_orientation_on_phone_platform_reminder
      "#{applicant.full_name},\nEn tant que bénéficiaire du RSA, vous avez reçu un message il y a 3 jours vous " \
        "invitant à contacter la plateforme départementale afin de démarrer un parcours d’accompagnement. " \
        "Vous n'avez plus que #{@invitation.number_of_days_before_expiration} jours pour appeler le " \
        "#{@invitation.help_phone_number}. Cet appel est obligatoire pour le traitement de votre dossier."
    end

    def content_for_rsa_cer_signature_reminder
      "#{applicant.full_name},\nEn tant que bénéficiaire du RSA, vous avez reçu un message il y a 3 jours " \
        "vous invitant à prendre RDV au créneau de votre choix afin de signer votre Contrat d'Engagement Réciproque. " \
        "Le lien de prise de RDV suivant expire dans #{@invitation.number_of_days_before_expiration} jours: " \
        "#{redirect_invitations_url(params: { uuid: @invitation.uuid }, host: ENV['HOST'])}\n" \
        "Ce rendez-vous est obligatoire. En cas de problème technique, contactez le "\
        "#{@invitation.help_phone_number}."
    end
  end
end
