module Notifications
  class RdvCreated < Notifications::NotifyApplicant
    protected

    def content
      rdv_presential? ? presential_content : remote_content
    end

    def presential_content
      "#{@applicant.full_name},\nVous êtes allocataire du RSA. Vous bénéficiez d’un accompagnement pour" \
        " vos démarches d’insertion. Vous êtes attendu(e) le #{formatted_start_date} à " \
        "#{formatted_start_time} ici: #{lieu.name} - #{lieu.address}. Ce RDV est obligatoire. "\
        "En cas d’empêchement, appelez rapidement le #{@organisation.phone_number}. "\
        "Le département #{@organisation.number} (#{@organisation.name.capitalize})."
    end

    def remote_content
      "#{@applicant.full_name},\nVous êtes allocataire du RSA. Vous bénéficiez d’un accompagnement" \
        " dans le cadre de vos démarches d’insertion. Un travailleur social vous appellera le #{formatted_start_date}" \
        " à partir de #{formatted_start_time} sur ce numéro. Ce rendez-vous est obligatoire. "\
        "En cas d’empêchement, merci d’appeler rapidement le " \
        "#{@organisation.phone_number}. Le département #{@organisation.number} (#{@organisation.name.capitalize})."
    end
  end
end
