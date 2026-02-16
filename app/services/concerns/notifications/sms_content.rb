# rubocop:disable Metrics/ModuleLength
module Notifications
  module SmsContent
    delegate :rdv, :user, :rdv_title, :rdv_title_by_phone, :user_designation, :mandatory_warning,
             :punishable_warning, :rdv_subject,
             to: :notification
    delegate :formatted_start_date, :formatted_start_time, :lieu, :phone_number, to: :rdv

    private

    ### participation_created

    def presential_participation_created_content
      "Bonjour #{user},\nVous êtes #{user_designation} et êtes " \
        "#{user.conjugate('convoqué')} à un " \
        "#{rdv_title}. Vous êtes #{user.conjugate('attendu')} le #{formatted_start_date} à " \
        "#{formatted_start_time} à : #{lieu.full_name}. " \
        "#{mandatory_warning_message}" \
        "#{punishable_warning_message}" \
        "En cas d'empêchement, contactez le #{formatted_phone_number}."
    end

    def by_phone_participation_created_content
      "Bonjour #{user},\nVous êtes #{user_designation} et êtes " \
        "#{user.conjugate('convoqué')} à un " \
        "#{rdv_title_by_phone}. Un conseiller d'insertion vous appellera le #{formatted_start_date}" \
        " à partir de #{formatted_start_time} sur ce numéro. " \
        "#{mandatory_warning_message}" \
        "#{punishable_warning_message}" \
        "En cas d'empêchement, contactez le #{formatted_phone_number}."
    end

    def visio_participation_created_content
      "Bonjour #{user},\nVous êtes #{user_designation} et êtes " \
        "#{user.conjugate('convoqué')} à un " \
        "#{rdv_title} par visio. Vous devez vous connecter le #{formatted_start_date} à " \
        "#{formatted_start_time} sur ce lien : #{rdv.visio_url}\n" \
        "#{mandatory_warning_message}" \
        "#{punishable_warning_message}" \
        "En cas d'empêchement, contactez le #{formatted_phone_number}."
    end

    ### participation_updated

    def presential_participation_updated_content
      "Bonjour #{user},\nVotre #{rdv_title} dans le cadre de votre #{rdv_subject} a été modifié. " \
        "Vous êtes #{user.conjugate('attendu')} le #{formatted_start_date} à #{formatted_start_time}" \
        " à : #{lieu.full_name}. " \
        "#{mandatory_warning_message}" \
        "#{punishable_warning_message}" \
        "En cas d'empêchement, contactez le #{formatted_phone_number}."
    end

    def by_phone_participation_updated_content
      "Bonjour #{user},\nVotre #{rdv_title_by_phone} dans le cadre de votre #{rdv_subject} a été modifié. " \
        "Un conseiller d'insertion vous appellera le #{formatted_start_date}" \
        " à partir de #{formatted_start_time} sur ce numéro. " \
        "#{mandatory_warning_message}" \
        "#{punishable_warning_message}" \
        "En cas d'empêchement, contactez le #{formatted_phone_number}."
    end

    def visio_participation_updated_content
      "Bonjour #{user},\nVotre #{rdv_title} par visio dans le cadre de votre #{rdv_subject} a été modifié. " \
        "Vous devez vous connecter le #{formatted_start_date} à #{formatted_start_time} " \
        "sur ce lien : #{rdv.visio_url}\n" \
        "#{mandatory_warning_message}" \
        "#{punishable_warning_message}" \
        "En cas d'empêchement, contactez le #{formatted_phone_number}."
    end

    ### participation_reminder

    def presential_participation_reminder_content
      "Rappel: Bonjour #{user},\nVous êtes #{user_designation} et avez été " \
        "#{user.conjugate('convoqué')} à un " \
        "#{rdv_title}. Vous êtes #{user.conjugate('attendu')} le #{formatted_start_date} à " \
        "#{formatted_start_time} à : #{lieu.full_name}. " \
        "#{mandatory_warning_message}" \
        "#{punishable_warning_message}" \
        "En cas d'empêchement, contactez le #{formatted_phone_number}."
    end

    def by_phone_participation_reminder_content
      "Rappel: Bonjour #{user},\nVous êtes #{user_designation} et avez été " \
        "#{user.conjugate('convoqué')} à un " \
        "#{rdv_title_by_phone}. Un conseiller d'insertion vous appellera le #{formatted_start_date}" \
        " à partir de #{formatted_start_time} sur ce numéro. " \
        "#{mandatory_warning_message}" \
        "#{punishable_warning_message}" \
        "En cas d'empêchement, contactez le #{formatted_phone_number}."
    end

    def visio_participation_reminder_content
      "Rappel: Bonjour #{user},\nVous êtes #{user_designation} et avez été " \
        "#{user.conjugate('convoqué')} à un " \
        "#{rdv_title} par visio. Vous devez vous connecter le #{formatted_start_date} à " \
        "#{formatted_start_time} sur ce lien : #{rdv.visio_url}\n" \
        "#{mandatory_warning_message}" \
        "#{punishable_warning_message}" \
        "En cas d'empêchement, contactez le #{formatted_phone_number}."
    end

    ### participation_cancelled

    def participation_cancelled_content
      "Bonjour #{user},\nVotre #{rdv_title} du #{formatted_start_date} à #{formatted_start_time} " \
        "dans le cadre de votre #{rdv_subject} a été annulé. " \
        "Pour plus d'informations, contactez le #{formatted_phone_number}."
    end

    ###

    def mandatory_warning_message
      mandatory_warning ? "#{mandatory_warning}. " : ""
    end

    def punishable_warning_message
      if punishable_warning.present?
        "En cas d'absence, #{punishable_warning}. "
      else
        ""
      end
    end

    def formatted_phone_number
      phone_number.gsub(" ", "")
    end
  end
end
# rubocop:enable Metrics/ModuleLength
