module Notifications
  module SmsContent
    private

    include Notifications::SmsContents::RsaOrientation
    include Notifications::SmsContents::RsaAccompagnement
    include Notifications::SmsContents::RsaCerSignature

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
  end
end
