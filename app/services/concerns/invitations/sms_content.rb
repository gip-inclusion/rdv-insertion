module Invitations
  module SmsContent
    extend ActiveSupport::Concern

    include Rails.application.routes.url_helpers

    delegate :applicant, :help_phone_number, :number_of_days_to_accept_invitation,
             :number_of_days_before_expiration, :rdv_purpose, :rdv_title, :applicant_designation,
             :display_mandatory_warning, :display_punishable_warning,
             to: :invitation

    private

    def short_content
      "#{applicant.full_name},\n Vous êtes #{applicant.conjugate('invité')} à prendre un #{rdv_title}." \
        " Pour choisir la date et l'horaire du RDV, " \
        "cliquez sur le lien suivant: " \
        "#{redirect_invitations_url(params: { uuid: @invitation.uuid }, host: ENV['HOST'])}\n" \
        "En cas de problème technique, contactez le #{help_phone_number}."
    end

    def standard_content
      "#{applicant.full_name},\nVous êtes #{applicant_designation} et vous devez vous présenter à un #{rdv_title}." \
        " Pour choisir la date et l'horaire du RDV, " \
        "cliquez sur le lien suivant dans les #{number_of_days_to_accept_invitation} jours: " \
        "#{redirect_invitations_url(params: { uuid: @invitation.uuid }, host: ENV['HOST'])}\n" \
        "#{mandatory_warning}" \
        "#{punishable_warning}" \
        "En cas de problème technique, contactez le #{help_phone_number}."
    end

    def phone_platform_content
      "#{applicant.full_name},\nVous êtes #{applicant_designation} et vous devez contacter la plateforme " \
        "départementale afin de #{rdv_purpose}. Pour cela, merci d'appeler le " \
        "#{help_phone_number} dans un délai de #{number_of_days_to_accept_invitation} jours. " \
        "Cet appel est nécessaire pour le traitement de votre dossier."
    end

    def atelier_content
      "#{applicant.full_name},\nVous êtes #{applicant_designation} et bénéficiez d'un accompagnement. " \
        "Pour en profiter au mieux, nous vous invitons " \
        "à vous inscrire directement et librement aux ateliers et formations de votre choix en cliquant sur le lien " \
        "suivant: #{redirect_invitations_url(params: { uuid: @invitation.uuid }, host: ENV['HOST'])}\n" \
        "En cas de problème technique, contactez le #{help_phone_number}."
    end

    ### Reminders

    def standard_reminder_content
      "#{applicant.full_name},\nEn tant que #{applicant_designation}, vous avez reçu un message il y a 3 jours " \
        "vous invitant à prendre RDV au créneau de votre choix afin de #{rdv_purpose}." \
        " Le lien de prise de RDV suivant expire dans #{number_of_days_before_expiration} " \
        "jours: " \
        "#{redirect_invitations_url(params: { uuid: @invitation.uuid }, host: ENV['HOST'])}\n" \
        "#{mandatory_warning}" \
        "#{punishable_warning}" \
        "En cas de problème technique, contactez le #{help_phone_number}."
    end

    def phone_platform_reminder_content
      "#{applicant.full_name},\nEn tant que #{applicant_designation}, vous avez reçu un message il y a 3 jours vous " \
        "invitant à contacter la plateforme départementale afin de #{rdv_purpose}. " \
        "Vous n'avez plus que #{number_of_days_before_expiration} jours pour appeler le " \
        "#{help_phone_number}. Cet appel est obligatoire pour le traitement de votre dossier."
    end

    ###

    def mandatory_warning
      display_mandatory_warning ? "Ce rendez-vous est obligatoire. " : ""
    end

    def punishable_warning
      if display_punishable_warning
        "En l'absence d'action de votre part, le versement de votre RSA pourra être suspendu ou réduit. "
      else
        ""
      end
    end
  end
end
