module Notifications
  class RdvCancelled < Notifications::NotifyApplicant
    protected

    def content
      "#{@applicant.full_name},\nVotre RDV d'orientation RSA a été annulé. " \
        "Veuillez contacter le #{@organisation.phone_number} pour plus d'informations."
    end
  end
end
