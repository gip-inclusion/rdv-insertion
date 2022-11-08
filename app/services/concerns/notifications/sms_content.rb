module Notifications
  module SmsContent
    include Templatable

    private

    ### rdv_created
    def presential_content_for_rdv_created
      "#{applicant.full_name},\nVous êtes allocataire du RSA et à ce titre vous avez été convoqué(e) à un " \
        "#{rdv_title}. Vous êtes attendu(e) le #{formatted_start_date} à " \
        "#{formatted_start_time} ici: #{lieu.full_name}. " \
        "#{mandatory_warning}"\
        "#{punishable_warning}" \
        "En cas d’empêchement, appelez rapidement le #{phone_number}."
    end

    def by_phone_content_for_rdv_created
      "#{applicant.full_name},\nVous êtes allocataire du RSA et à ce titre vous avez été convoqué(e) à un " \
        "#{rdv_title}. Un travailleur social vous appellera le #{formatted_start_date}" \
        " à partir de #{formatted_start_time} sur ce numéro. " \
        "#{mandatory_warning}"\
        "#{punishable_warning}" \
        "En cas d’empêchement, appelez rapidement le #{phone_number}."
    end

    ### rdv_updated
    def presential_content_for_rdv_updated
      "#{applicant.full_name},\nVotre #{rdv_title} dans le cadre de votre RSA a été modifié. " \
        "Vous êtes attendu(e) le #{formatted_start_date} à #{formatted_start_time}" \
        " ici: #{lieu.full_name}. " \
        "#{mandatory_warning}"\
        "#{punishable_warning}" \
        "En cas d’empêchement, appelez rapidement le #{phone_number}."
    end

    def by_phone_content_for_rdv_updated
      "#{applicant.full_name},\nVotre #{rdv_title} dans le cadre de votre RSA a été modifié. " \
        "Un travailleur social vous appellera le #{formatted_start_date}" \
        " à partir de #{formatted_start_time} sur ce numéro. " \
        "#{mandatory_warning}"\
        "#{punishable_warning}" \
        "En cas d’empêchement, appelez rapidement le #{phone_number}."
    end

    ### rdv_cancelled
    def content_for_rdv_cancelled
      "#{applicant.full_name},\nVotre #{rdv_title} dans le cadre de votre RSA a été annulé. " \
        "Pour plus d'informations, contactez le #{phone_number}."
    end

    def mandatory_warning
      display_mandatory_warning ? 'Ce RDV est obligatoire. ' : ''
    end

    def punishable_warning
      if display_punishable_warning
        "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit. "
      else
        ''
      end
    end

    def formatted_start_date
      rdv.formatted_start_date
    end

    def formatted_start_time
      rdv.formatted_start_time
    end

    def lieu
      rdv.lieu
    end

    def department_number
      applicant.department_number
    end

    def department_name
      applicant.department_name
    end

    def phone_number
      rdv.phone_number
    end

    def motif_category
      rdv.motif_category
    end
  end
end
