module Notifications
  class RdvCreated < Notifications::NotifyApplicant
    protected

    def content
      rdv_presential? ? presential_content : remote_content
    end

    def presential_content
      "#{@applicant.full_name},\nVous êtes allocataire du RSA. Vous bénéficiez d’un accompagnement obligatoire" \
        "dans le cadre de vos démarches d’insertion. Vous êtes attendu(e) le #{formatted_start_date} à " \
        "#{formatted_start_time} ici: #{@lieu[:name]} - #{@lieu[:address]}. En cas d’empêchement, merci "\
        "d’appeler rapidement le #{department.phone_number}. En cas d’absence, vous risquez une " \
        "suspension de votre allocation RSA. Le département #{department.number} (#{department.name.capitalize})."
    end

    def remote_content
      "#{@applicant.full_name},\nVous êtes allocataire du RSA. Vous bénéficiez d’un accompagnement obligatoire" \
        " dans le cadre de vos démarches d’insertion. Un travailleur social vous appellera le #{formatted_start_date}" \
        " à partir de #{formatted_start_time} sur ce numéro. En cas d’empêchement, merci d’appeler rapidement le " \
        "#{department.phone_number}. En cas d’absence, vous risquez une uspension de votre allocation RSA." \
        " Le département #{department.number} (#{department.name.capitalize})."
    end
  end
end
