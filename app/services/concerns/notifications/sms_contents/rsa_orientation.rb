module Notifications
  module SmsContents
    module RsaOrientation
      ############# for rsa_orientation ##########

      ### rdv_created
      def presential_content_for_rsa_orientation_rdv_created
        "#{applicant.full_name},\nVous êtes allocataire du RSA et vous devez vous présenter à un rendez-vous" \
          " d'accompagnement. Vous êtes attendu(e) le #{formatted_start_date} à " \
          "#{formatted_start_time} ici: #{lieu.full_name}. Ce RDV est obligatoire. "\
          "En cas d’empêchement, merci d'appeler rapidement le #{phone_number}. "\
      end

      def by_phone_content_for_rsa_orientation_rdv_created
        "#{applicant.full_name},\nVous êtes allocataire du RSA et vous devez vous présenter à un rendez-vous" \
          " d'accompagnement. Un travailleur social vous appellera le #{formatted_start_date}" \
          " à partir de #{formatted_start_time} sur ce numéro. Ce rendez-vous est obligatoire. "\
          "En cas d’empêchement, merci d'appeler rapidement le #{phone_number}."
      end

      ### rdv_updated
      def presential_content_for_rsa_orientation_rdv_updated
        "#{applicant.full_name},\nVotre RDV d'orientation RSA a été modifié. " \
          "Vous êtes attendu(e) le #{formatted_start_date} à #{formatted_start_time}" \
          " ici: #{lieu.full_name}. Ce RDV est obligatoire. " \
          "En cas d’empêchement, merci d’appeler rapidement le #{phone_number}."
      end

      def by_phone_content_for_rsa_orientation_rdv_updated
        "#{applicant.full_name},\nVotre RDV d'orientation RSA a été modifié. " \
          "Un travailleur social vous appellera le #{formatted_start_date}" \
          " à partir de #{formatted_start_time} sur ce numéro. " \
          "En cas d’empêchement, merci d’appeler rapidement le #{phone_number}."
      end

      ### rdv_cancelled
      def content_for_rsa_orientation_rdv_cancelled
        "#{applicant.full_name},\nVotre RDV d'orientation RSA a été annulé. " \
          "Pour plus d'informations, contactez le #{phone_number}."
      end
    end
  end
end
