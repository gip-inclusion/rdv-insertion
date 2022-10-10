module Notifications
  module SmsContent
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

    def applicant
      @notification.applicant
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

    def category_settings
      @category_settings ||= Settings::MotifCategory.send(:"#{motif_category}")
    end

    def rdv_title
      @rdv_title ||= begin
        rdv_title = category_settings.rdv_title
        raise_for_missing_attribute("rdv_title") if rdv_title.nil?
        rdv_title
      end
    end

    def display_mandatory_warning
      @display_mandatory_warning ||= begin
        display_mandatory_warning = category_settings.display_mandatory_warning
        raise_for_missing_attribute("display_mandatory_warning") if display_mandatory_warning.nil?
        display_mandatory_warning
      end
    end

    def display_punishable_warning
      @display_punishable_warning ||= begin
        display_punishable_warning = category_settings.display_punishable_warning
        raise_for_missing_attribute("display_punishable_warning") if display_punishable_warning.nil?
        display_punishable_warning
      end
    end

    def raise_for_missing_attributes(attribute)
      raise SmsNotificationError, "#{attribute} not found for category #{motif_category}"
    end
  end
end
