# rubocop:disable Metrics/ModuleLength
module Invitations
  module SmsContent
    extend ActiveSupport::Concern

    delegate :user, :help_phone_number, :number_of_days_before_expiration, :motif_category,
             :rdv_purpose, :rdv_title, :user_designation, :mandatory_warning, :punishable_warning,
             to: :invitation

    private

    def short_content
      "#{user.full_name},\nVous êtes #{user.conjugate('invité')} à prendre un #{rdv_title}." \
        " Pour choisir la date du RDV, " \
        "cliquez sur ce lien: " \
        "#{@invitation.rdv_solidarites_public_url(with_protocol: false)}\n" \
        "#{mandatory_warning_message}" \
        "#{punishable_warning_message}" \
        "En cas de problème, contactez le #{formatted_phone_number}."
    end

    def standard_content
      "#{user.full_name},\nVous êtes #{user_designation} et êtes #{user.conjugate('invité')} à" \
        " participer à un #{rdv_title}. Pour choisir la date du RDV, " \
        "cliquez sur ce lien#{display_time_to_accept_invitation}: " \
        "#{@invitation.rdv_solidarites_public_url(with_protocol: false)}\n" \
        "#{mandatory_warning_message}" \
        "#{punishable_warning_message}" \
        "En cas de problème, contactez le #{formatted_phone_number}."
    end

    def phone_platform_content
      "#{user.full_name},\nVous êtes #{user_designation} et devez contacter la plateforme " \
        "départementale afin de #{rdv_purpose}. Pour cela, merci d'appeler le " \
        "#{formatted_phone_number}#{display_time_to_accept_invitation}. " \
        "#{mandatory_warning_message}" \
        "#{punishable_warning_message}"
    end

    def atelier_content
      "#{user.full_name},\nVous êtes #{user_designation} et bénéficiez d'un accompagnement. " \
        "Vous pouvez consulter le(s) atelier(s) et formation(s) proposé(s) et vous y inscrire directement et " \
        "librement, dans la limite des places disponibles, en cliquant sur ce lien:" \
        " #{@invitation.rdv_solidarites_public_url(with_protocol: false)}\n" \
        "#{mandatory_warning_message}" \
        "#{punishable_warning_message}" \
        "En cas de problème, contactez le #{formatted_phone_number}."
    end

    def atelier_enfants_ados_content
      "#{user},\nTu es #{user.conjugate('invité')} à participer à un atelier organisé par le département. " \
        "Nous te proposons de cliquer ci-dessous pour découvrir le programme. " \
        "Si tu es #{user.conjugate('intéressé')} pour participer, tu n’auras qu’à cliquer et t’inscrire en ligne" \
        " avec le lien suivant: #{@invitation.rdv_solidarites_public_url(with_protocol: false)}\n" \
        "En cas de problème, tu peux contacter le #{formatted_phone_number}."
    end

    ### Reminders

    def short_reminder_content
      "#{user.full_name},\nVous avez reçu un message il y a #{Invitation::NUMBER_OF_DAYS_BEFORE_REMINDER} jours " \
        "vous invitant à prendre un #{rdv_title}." \
        " Ce lien de prise de RDV expire dans #{number_of_days_before_expiration} " \
        "jours: " \
        "#{@invitation.rdv_solidarites_public_url(with_protocol: false)}\n" \
        "#{mandatory_warning_message}" \
        "#{punishable_warning_message}" \
        "En cas de problème, contactez le #{formatted_phone_number}."
    end

    def standard_reminder_content
      "#{user.full_name},\nEn tant que #{user_designation}, vous avez reçu un message il y a " \
        "#{Invitation::NUMBER_OF_DAYS_BEFORE_REMINDER} jours vous invitant à prendre RDV au créneau de votre choix " \
        "afin de #{rdv_purpose}. Ce lien de prise de RDV expire dans #{number_of_days_before_expiration} " \
        "jours: " \
        "#{@invitation.rdv_solidarites_public_url(with_protocol: false)}\n" \
        "#{mandatory_warning_message}" \
        "#{punishable_warning_message}" \
        "En cas de problème, contactez le #{formatted_phone_number}."
    end

    def phone_platform_reminder_content
      "#{user.full_name},\nEn tant que #{user_designation}, vous avez reçu un message il y a " \
        "#{Invitation::NUMBER_OF_DAYS_BEFORE_REMINDER} jours vous invitant à contacter la plateforme départementale " \
        "afin de #{rdv_purpose}. Il vous reste #{number_of_days_before_expiration} jours pour appeler le " \
        "#{formatted_phone_number}. " \
        "#{mandatory_warning_message}" \
        "#{punishable_warning_message}"
    end

    def atelier_enfants_ados_reminder_content
      "#{user.full_name},\nTu as reçu un message il y a #{Invitation::NUMBER_OF_DAYS_BEFORE_REMINDER} jours " \
        "t'invitant à participer à un #{rdv_title}." \
        " Le lien de prise de RDV suivant expire dans #{number_of_days_before_expiration} jours: " \
        "#{@invitation.rdv_solidarites_public_url(with_protocol: false)}\n" \
        "#{mandatory_warning_message}" \
        "#{punishable_warning_message}" \
        "En cas de problème, tu peux contacter le #{formatted_phone_number}."
    end

    def atelier_reminder_content
      "RAPPEL : #{atelier_content}"
    end

    ###

    def display_time_to_accept_invitation
      " dans les #{Invitation::NUMBER_OF_DAYS_BEFORE_REMINDER} jours" if invitation.expireable?
    end

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

    def formatted_phone_number
      help_phone_number.gsub(" ", "")
    end
  end
end

# rubocop:enable Metrics/ModuleLength
