module Invitations
  class SendSms < BaseService
    def initialize(invitation:, phone_number:)
      @invitation = invitation
      @phone_number = phone_number
    end

    def call
      check_phone_number!
      send_sms
    end

    private

    def check_phone_number!
      fail!("le téléphone doit être renseigné") if @phone_number.blank?
    end

    def send_sms
      Rails.logger.info(content)
      return if Rails.env.development?

      SendTransactionalSms.call(phone_number: @phone_number, content: content)
    end

    def content
      "Bonjour,\nVous êtes allocataire du RSA. Vous bénéficiez d'un accompagenement obligatoire dans le cadre de " \
        "vos démarches d'insertion. Le département #{department.number} (#{department.name.capitalize}) " \
        "vous invite à prendre rendez-vous à l'adresse suivante: #{@invitation.link}\n" \
        "En cas d'absence, une sanction pourra être prononcée. Pour tout problème ou difficultés pour prendre RDV, " \
        "contactez le secrétariat au #{department.phone_number}."
    end

    def department
      @invitation.department
    end

    def applicant
      @invitation.applicant
    end
  end
end
