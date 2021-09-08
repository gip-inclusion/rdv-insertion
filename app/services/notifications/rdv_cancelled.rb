module Notifications
  class RdvCancelled < Notifications::NotifyApplicant
    protected

    def content
      "#{@applicant.full_name},\n Votre RDV d'orientation RSA a été annulé. " \
        "Veuillez contacter le #{department.phone_number} pour plus d'informations."
    end

    def event
      "rdv_cancelled"
    end
  end
end
