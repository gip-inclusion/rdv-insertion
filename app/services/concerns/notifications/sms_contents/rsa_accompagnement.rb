module Notifications
  module SmsContents
    module RsaAccompagnement
      ############# for rsa_accompagnement ##########

      ### rdv_created
      def presential_content_for_rsa_accompagnement_rdv_created
        "#{applicant.full_name},\nVous êtes allocataire du RSA et vous devez vous présenter à un rendez-vous" \
          " d'accompagnement. Vous êtes attendu(e) le #{formatted_start_date} à " \
          "#{formatted_start_time} ici: #{lieu.full_name}. Ce RDV est obligatoire. "\
          "En l’absence d'action de votre part, le versement de votre RSA pourra être suspendu ou réduit. " \
          "En cas d’empêchement, appelez rapidement le #{phone_number}. "\
      end

      def by_phone_content_for_rsa_accompagnement_rdv_created
        "#{applicant.full_name},\nVous êtes allocataire du RSA et vous devez vous présenter à un rendez-vous" \
          " d'accompagnement. Un travailleur social vous appellera le #{formatted_start_date}" \
          " à partir de #{formatted_start_time} sur ce numéro. Ce rendez-vous est obligatoire. " \
          "En l’absence d'action de votre part, le versement de votre RSA pourra être suspendu ou réduit. " \
          "En cas d’empêchement, merci d’appeler rapidement le #{phone_number}."
      end

      ### rdv_updated
      def presential_content_for_rsa_accompagnement_rdv_updated
        "#{applicant.full_name},\nVotre RDV d'accompagnement RSA a été modifié. " \
          "Vous êtes attendu(e) le #{formatted_start_date} à #{formatted_start_time}" \
          " ici: #{lieu.full_name}. Ce RDV est obligatoire. " \
          "En l’absence d'action de votre part, le versement de votre RSA pourra être suspendu ou réduit. " \
          "En cas d’empêchement, merci d’appeler rapidement le #{phone_number}."
      end

      def by_phone_content_for_rsa_accompagnement_rdv_updated
        "#{applicant.full_name},\nVotre RDV d'accompagnement RSA a été modifié. " \
          "Un travailleur social vous appellera le #{formatted_start_date}" \
          " à partir de #{formatted_start_time} sur ce numéro. " \
          "En l’absence d'action de votre part, le versement de votre RSA pourra être suspendu ou réduit. " \
          "En cas d’empêchement, merci d’appeler rapidement le #{phone_number}."
      end

      ### rdv_cancelled
      def content_for_accompagnement_rdv_cancelled
        "#{applicant.full_name},\nVotre RDV d'accompagnement RSA a été annulé. " \
          "Pour plus d'informations, contactez le #{phone_number}."
      end
    end
  end
end
