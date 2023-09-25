module Invitations
  module SmsContent
    extend ActiveSupport::Concern

    include Rails.application.routes.url_helpers

    delegate :user, :help_phone_number, :number_of_days_before_expiration,
             :rdv_purpose, :rdv_title, :user_designation, :mandatory_warning, :punishable_warning,
             to: :invitation

    private

    def short_content
      "#{user.full_name},\nVous êtes #{user.conjugate('invité')} à prendre un #{rdv_title}." \
        " Pour choisir la date et l'horaire du RDV, " \
        "cliquez sur le lien suivant: " \
        "#{redirect_invitations_url(params: { uuid: @invitation.uuid }, host: ENV['HOST'])}\n" \
        "#{mandatory_warning_message}" \
        "#{punishable_warning_message}" \
        "En cas de problème, contactez le #{help_phone_number}."
    end

    def standard_content
      "#{user.full_name},\nVous êtes #{user_designation} et vous êtes #{user.conjugate('invité')} à" \
        " participer à un #{rdv_title}. Pour choisir la date et l'horaire du RDV, " \
        "cliquez sur le lien suivant dans les #{Invitation::NUMBER_OF_DAYS_BEFORE_REMINDER} jours: " \
        "#{redirect_invitations_url(params: { uuid: @invitation.uuid }, host: ENV['HOST'])}\n" \
        "#{mandatory_warning_message}" \
        "#{punishable_warning_message}" \
        "En cas de problème, contactez le #{help_phone_number}."
    end

    def phone_platform_content
      "#{user.full_name},\nVous êtes #{user_designation} et vous devez contacter la plateforme " \
        "départementale afin de #{rdv_purpose}. Pour cela, merci d'appeler le " \
        "#{help_phone_number} dans un délai de #{Invitation::NUMBER_OF_DAYS_BEFORE_REMINDER} jours. " \
        "#{mandatory_warning_message}" \
        "#{punishable_warning_message}"
    end

    def atelier_content
      "#{user.full_name},\nVous êtes #{user_designation} et bénéficiez d'un accompagnement. " \
        "Pour en profiter au mieux, nous vous invitons " \
        "à vous inscrire directement et librement aux ateliers et formations de votre choix en cliquant sur le lien " \
        "suivant: #{redirect_invitations_url(params: { uuid: @invitation.uuid }, host: ENV['HOST'])}\n" \
        "#{mandatory_warning_message}" \
        "#{punishable_warning_message}" \
        "En cas de problème, contactez le #{help_phone_number}."
    end

    def atelier_enfants_ados_content
      "#{user},\nTu es #{user.conjugate('invité')} à participer à un atelier organisé par le département. " \
        "Nous te proposons de cliquer ci-dessous pour découvrir le programme. " \
        "Si tu es #{user.conjugate('intéressé')} pour participer, tu n’auras qu’à cliquer et t’inscrire en ligne" \
        " avec le lien suivant: #{redirect_invitations_url(params: { uuid: @invitation.uuid }, host: ENV['HOST'])}\n" \
        "En cas de problème, tu peux contacter le #{help_phone_number}."
    end

    ### Reminders

    def short_reminder_content
      "#{user.full_name},\nVous avez reçu un message il y a 3 jours " \
        "vous invitant à prendre un #{rdv_title}." \
        " Le lien de prise de RDV suivant expire dans #{number_of_days_before_expiration} " \
        "jours: " \
        "#{redirect_invitations_url(params: { uuid: @invitation.uuid }, host: ENV['HOST'])}\n" \
        "#{mandatory_warning_message}" \
        "#{punishable_warning_message}" \
        "En cas de problème, contactez le #{help_phone_number}."
    end

    def standard_reminder_content
      "#{user.full_name},\nEn tant que #{user_designation}, vous avez reçu un message il y a 3 jours " \
        "vous invitant à prendre RDV au créneau de votre choix afin de #{rdv_purpose}." \
        " Le lien de prise de RDV suivant expire dans #{number_of_days_before_expiration} " \
        "jours: " \
        "#{redirect_invitations_url(params: { uuid: @invitation.uuid }, host: ENV['HOST'])}\n" \
        "#{mandatory_warning_message}" \
        "#{punishable_warning_message}" \
        "En cas de problème, contactez le #{help_phone_number}."
    end

    def phone_platform_reminder_content
      "#{user.full_name},\nEn tant que #{user_designation}, vous avez reçu un message il y a 3 jours vous " \
        "invitant à contacter la plateforme départementale afin de #{rdv_purpose}. " \
        "Vous n'avez plus que #{number_of_days_before_expiration} jours pour appeler le " \
        "#{help_phone_number}. " \
        "#{mandatory_warning_message}" \
        "#{punishable_warning_message}"
    end

    def atelier_enfants_ados_reminder_content
      "#{user.full_name},\nTu as reçu un message il y a 3 jours " \
        "t'invitant à participer à un #{rdv_title}." \
        " Le lien de prise de RDV suivant expire dans #{number_of_days_before_expiration} " \
        "jours: " \
        "#{redirect_invitations_url(params: { uuid: @invitation.uuid }, host: ENV['HOST'])}\n" \
        "#{mandatory_warning_message}" \
        "#{punishable_warning_message}" \
        "En cas de problème, tu peux contacter le #{help_phone_number}."
    end

    ###

    def mandatory_warning_message
      mandatory_warning ? "#{mandatory_warning} " : ""
    end

    def punishable_warning_message
      if punishable_warning.present?
        "En l'absence d'action de votre part, #{punishable_warning}. "
      else
        ""
      end
    end
  end
end
