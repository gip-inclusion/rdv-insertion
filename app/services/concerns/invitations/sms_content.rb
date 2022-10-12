module Invitations
  # rubocop:disable Metrics/ModuleLength
  module SmsContent
    extend ActiveSupport::Concern

    include Rails.application.routes.url_helpers

    private

    def number_of_days_to_accept_invitation
      @invitation.number_of_days_to_accept_invitation
    end

    def number_of_days_before_expiration
      @invitation.number_of_days_before_expiration
    end

    def applicant
      @invitation.applicant
    end

    def help_phone_number
      @invitation.help_phone_number
    end

    def content_for_rsa_orientation
      "#{applicant.full_name},\nVous êtes bénéficiaire du RSA et vous devez vous présenter à un rendez-vous " \
        "d'orientation. Pour choisir la date et l'horaire de votre premier RDV, " \
        "cliquez sur le lien suivant dans les #{number_of_days_to_accept_invitation} jours: " \
        "#{redirect_invitations_url(params: { uuid: @invitation.uuid }, host: ENV['HOST'])}\n" \
        "Ce rendez-vous est obligatoire. En cas de problème technique, contactez le "\
        "#{help_phone_number}."
    end

    def content_for_rsa_accompagnement
      "#{applicant.full_name},\nVous êtes bénéficiaire du RSA et vous devez vous présenter à un rendez-vous " \
        "d'accompagnement. Pour choisir la date et l'horaire de votre premier RDV, " \
        "cliquez sur le lien suivant dans les #{number_of_days_to_accept_invitation} jours: " \
        "#{redirect_invitations_url(params: { uuid: @invitation.uuid }, host: ENV['HOST'])}\n" \
        "Ce rendez-vous est obligatoire. En l’absence d'action de votre part, " \
        "le versement de votre RSA pourra être suspendu ou réduit. En cas de problème technique, contactez le "\
        "#{help_phone_number}."
    end

    def content_for_rsa_orientation_on_phone_platform
      "#{applicant.full_name},\nVous êtes bénéficiaire du RSA et vous devez contacter la plateforme départementale " \
        "afin de démarrer votre parcours d’accompagnement. Pour cela, merci d’appeler le " \
        "#{help_phone_number} dans un délai de #{number_of_days_to_accept_invitation} jours. "\
        "Cet appel est nécessaire pour le traitement de votre dossier."
    end

    def content_for_rsa_cer_signature
      "#{applicant.full_name},\nVous êtes bénéficiaire du RSA et à ce titre vous allez construire et signer "\
        "votre Contrat d'Engagement Réciproque. Pour cela, nous vous invitons à prendre RDV avec votre référent de " \
        "parcours. Pour choisir la date et l'horaire du RDV, cliquez sur le lien suivant dans un délai de " \
        "#{number_of_days_to_accept_invitation} jours: " \
        "#{redirect_invitations_url(params: { uuid: @invitation.uuid }, host: ENV['HOST'])}\n" \
        "En l'absence d'action de votre part, le versement de votre RSA pourra être suspendu ou réduit. "\
        "En cas de problème technique, contactez le #{help_phone_number}."
    end

    def content_for_rsa_insertion_offer
      "#{applicant.full_name},\nVous êtes bénéficiaire du RSA et bénéficiez d'un accompagnement en parcours "\
        "professionnel ou socio-professionel. Pour profiter au mieux de cet accompagnement, nous vous invitons "\
        "à vous inscrire directement et librement aux ateliers et formations de votre choix en cliquant sur le lien " \
        "suivant: #{redirect_invitations_url(params: { uuid: @invitation.uuid }, host: ENV['HOST'])}\n" \
        "En cas de problème technique, contactez le #{help_phone_number}."
    end

    def content_for_rsa_follow_up
      "#{applicant.full_name},\nVous êtes bénéficiaire du RSA et à ce titre vous êtes invité "\
        "par votre référent de parcours à un RDV de suivi. " \
        "Pour choisir la date et l'horaire du RDV, cliquez sur le lien suivant dans un délai de " \
        "#{number_of_days_to_accept_invitation} jours: " \
        "#{redirect_invitations_url(params: { uuid: @invitation.uuid }, host: ENV['HOST'])}\n" \
        "En cas de problème technique, contactez le #{help_phone_number}."
    end

    ### Reminders

    def content_for_rsa_orientation_reminder
      "#{applicant.full_name},\nEn tant que bénéficiaire du RSA, vous avez reçu un message il y a 3 jours " \
        "vous invitant à prendre RDV au créneau de votre choix afin de démarrer un parcours d’accompagnement." \
        " Le lien de prise de RDV suivant expire dans #{number_of_days_before_expiration} "\
        "jours: " \
        "#{redirect_invitations_url(params: { uuid: @invitation.uuid }, host: ENV['HOST'])}\n" \
        "Ce rendez-vous est obligatoire. En cas de problème technique, contactez le "\
        "#{help_phone_number}."
    end

    def content_for_rsa_accompagnement_reminder
      "#{applicant.full_name},\nEn tant que bénéficiaire du RSA, vous avez reçu un message il y a 3 jours " \
        "vous invitant à prendre RDV au créneau de votre choix afin de démarrer un parcours d’accompagnement." \
        " Le lien de prise de RDV suivant expire dans #{number_of_days_before_expiration} " \
        "jours: " \
        "#{redirect_invitations_url(params: { uuid: @invitation.uuid }, host: ENV['HOST'])}\n" \
        "Ce rendez-vous est obligatoire. En l’absence d'action de votre part, " \
        "le versement de votre RSA pourra être suspendu ou réduit. En cas de problème technique, contactez le "\
        "#{help_phone_number}."
    end

    def content_for_rsa_orientation_on_phone_platform_reminder
      "#{applicant.full_name},\nEn tant que bénéficiaire du RSA, vous avez reçu un message il y a 3 jours vous " \
        "invitant à contacter la plateforme départementale afin de démarrer un parcours d’accompagnement. " \
        "Vous n'avez plus que #{number_of_days_before_expiration} jours pour appeler le " \
        "#{help_phone_number}. Cet appel est obligatoire pour le traitement de votre dossier."
    end

    def content_for_rsa_cer_signature_reminder
      "#{applicant.full_name},\nEn tant que bénéficiaire du RSA, vous avez reçu un message il y a 3 jours " \
        "vous invitant à prendre RDV au créneau de votre choix afin de signer votre Contrat d'Engagement Réciproque. " \
        "Le lien de prise de RDV suivant expire dans #{number_of_days_before_expiration} jours: " \
        "#{redirect_invitations_url(params: { uuid: @invitation.uuid }, host: ENV['HOST'])}\n" \
        "Ce rendez-vous est obligatoire. En cas de problème technique, contactez le "\
        "#{help_phone_number}."
    end

    def content_for_rsa_insertion_offer_reminder
      "#{applicant.full_name},\nEn tant que bénéficiaire du RSA, vous avez reçu un message il y a 3 jours "\
        "vous invitant à vous inscrire directement à des ateliers adaptés à votre parcours d'accompagnement." \
        "Utilisez le lien suivant pour effectuer votre prise de RDV: " \
        "#{redirect_invitations_url(params: { uuid: @invitation.uuid }, host: ENV['HOST'])}\n" \
        "En cas de problème technique, contactez le #{help_phone_number}."
    end

    def content_for_rsa_follow_up_reminder
      "#{applicant.full_name},\nEn tant que bénéficiaire du RSA, vous avez reçu un message il y a 3 jours " \
        "vous invitant à prendre un RDV de suivi au créneau de votre choix." \
        "Le lien de prise de RDV suivant expire dans #{number_of_days_before_expiration} jours: " \
        "#{redirect_invitations_url(params: { uuid: @invitation.uuid }, host: ENV['HOST'])}\n" \
        "En cas de problème technique, contactez le "\
        "#{help_phone_number}."
    end
  end
  # rubocop:enable Metrics/ModuleLength
end
