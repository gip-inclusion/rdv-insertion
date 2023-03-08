module Notifications
  module SmsContent
    delegate :rdv, :applicant, :rdv_title, :applicant_designation, :display_mandatory_warning,
             :display_punishable_warning, :rdv_subject,
             to: :notification
    delegate :formatted_start_date, :formatted_start_time, :lieu, :phone_number, to: :rdv

    private

    ### participation_created
    def presential_content_for_participation_created
      "#{applicant.full_name},\nVous êtes #{applicant_designation} et à ce titre vous avez été " \
        "#{applicant.conjugate('convoqué')} à un " \
        "#{rdv_title}. Vous êtes #{applicant.conjugate('attendu')} le #{formatted_start_date} à " \
        "#{formatted_start_time} ici: #{lieu.full_name}. " \
        "#{mandatory_warning}" \
        "#{punishable_warning}" \
        "En cas d’empêchement, appelez rapidement le #{phone_number}."
    end

    def by_phone_content_for_participation_created
      "#{applicant.full_name},\nVous êtes #{applicant_designation} et à ce titre vous avez été " \
        "#{applicant.conjugate('convoqué')} à un " \
        "#{rdv_title}. Un travailleur social vous appellera le #{formatted_start_date}" \
        " à partir de #{formatted_start_time} sur ce numéro. " \
        "#{mandatory_warning}" \
        "#{punishable_warning}" \
        "En cas d’empêchement, appelez rapidement le #{phone_number}."
    end

    ### participation_updated
    def presential_content_for_participation_updated
      "#{applicant.full_name},\nVotre #{rdv_title} dans le cadre de votre #{rdv_subject} a été modifié. " \
        "Vous êtes #{applicant.conjugate('attendu')} le #{formatted_start_date} à #{formatted_start_time}" \
        " ici: #{lieu.full_name}. " \
        "#{mandatory_warning}" \
        "#{punishable_warning}" \
        "En cas d’empêchement, appelez rapidement le #{phone_number}."
    end

    def by_phone_content_for_participation_updated
      "#{applicant.full_name},\nVotre #{rdv_title} dans le cadre de votre #{rdv_subject} a été modifié. " \
        "Un travailleur social vous appellera le #{formatted_start_date}" \
        " à partir de #{formatted_start_time} sur ce numéro. " \
        "#{mandatory_warning}" \
        "#{punishable_warning}" \
        "En cas d’empêchement, appelez rapidement le #{phone_number}."
    end

    ### participation_cancelled
    def content_for_participation_cancelled
      "#{applicant.full_name},\nVotre #{rdv_title} dans le cadre de votre #{rdv_subject} a été annulé. " \
        "Pour plus d'informations, contactez le #{phone_number}."
    end

    ###

    def mandatory_warning
      display_mandatory_warning ? "Ce RDV est obligatoire. " : ""
    end

    def punishable_warning
      if display_punishable_warning
        "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit. "
      else
        ""
      end
    end
  end
end
