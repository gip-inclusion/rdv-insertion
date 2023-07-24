module Notifications
  module SmsContent
    delegate :rdv, :applicant, :rdv_title, :rdv_title_by_phone, :applicant_designation, :mandatory_warning,
             :punishable_warning, :rdv_subject,
             to: :notification
    delegate :formatted_start_date, :formatted_start_time, :lieu, :phone_number, to: :rdv

    private

    ### participation_created
    def presential_participation_created_content
      "#{applicant.full_name},\nVous êtes #{applicant_designation} et à ce titre vous êtes " \
        "#{applicant.conjugate('convoqué')} à un " \
        "#{rdv_title}. Vous êtes #{applicant.conjugate('attendu')} le #{formatted_start_date} à " \
        "#{formatted_start_time} ici: #{lieu.full_name}. " \
        "#{mandatory_warning_message}" \
        "#{punishable_warning_message}" \
        "En cas d’empêchement, appelez rapidement le #{phone_number}."
    end

    def by_phone_participation_created_content
      "#{applicant.full_name},\nVous êtes #{applicant_designation} et à ce titre vous êtes " \
        "#{applicant.conjugate('convoqué')} à un " \
        "#{rdv_title_by_phone}. Un travailleur social vous appellera le #{formatted_start_date}" \
        " à partir de #{formatted_start_time} sur ce numéro. " \
        "#{mandatory_warning_message}" \
        "#{punishable_warning_message}" \
        "En cas d’empêchement, appelez rapidement le #{phone_number}."
    end

    ### participation_updated
    def presential_participation_updated_content
      "#{applicant.full_name},\nVotre #{rdv_title} dans le cadre de votre #{rdv_subject} a été modifié. " \
        "Vous êtes #{applicant.conjugate('attendu')} le #{formatted_start_date} à #{formatted_start_time}" \
        " ici: #{lieu.full_name}. " \
        "#{mandatory_warning_message}" \
        "#{punishable_warning_message}" \
        "En cas d’empêchement, appelez rapidement le #{phone_number}."
    end

    def by_phone_participation_updated_content
      "#{applicant.full_name},\nVotre #{rdv_title_by_phone} dans le cadre de votre #{rdv_subject} a été modifié. " \
        "Un travailleur social vous appellera le #{formatted_start_date}" \
        " à partir de #{formatted_start_time} sur ce numéro. " \
        "#{mandatory_warning_message}" \
        "#{punishable_warning_message}" \
        "En cas d’empêchement, appelez rapidement le #{phone_number}."
    end

    ## participation_reminder
    def presential_participation_reminder_content
      "RAPPEL: #{applicant.full_name},\nVous êtes #{applicant_designation} et à ce titre vous avez été " \
        "#{applicant.conjugate('convoqué')} à un " \
        "#{rdv_title}. Vous êtes #{applicant.conjugate('attendu')} le #{formatted_start_date} à " \
        "#{formatted_start_time} ici: #{lieu.full_name}. " \
        "#{mandatory_warning_message}" \
        "#{punishable_warning_message}" \
        "En cas d’empêchement, appelez rapidement le #{phone_number}."
    end

    def by_phone_participation_reminder_content
      "RAPPEL: #{applicant.full_name},\nVous êtes #{applicant_designation} et à ce titre vous avez été " \
        "#{applicant.conjugate('convoqué')} à un " \
        "#{rdv_title_by_phone}. Un travailleur social vous appellera le #{formatted_start_date}" \
        " à partir de #{formatted_start_time} sur ce numéro. " \
        "#{mandatory_warning_message}" \
        "#{punishable_warning_message}" \
        "En cas d’empêchement, appelez rapidement le #{phone_number}."
    end

    ### participation_cancelled
    def participation_cancelled_content
      "#{applicant.full_name},\nVotre #{rdv_title} dans le cadre de votre #{rdv_subject} a été annulé. " \
        "Pour plus d'informations, contactez le #{phone_number}."
    end

    ###

    def mandatory_warning_message
      mandatory_warning ? "#{mandatory_warning} " : ""
    end

    def punishable_warning_message
      if punishable_warning.present?
        "En cas d'absence, #{punishable_warning}. "
      else
        ""
      end
    end
  end
end
