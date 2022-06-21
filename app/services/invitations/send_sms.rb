module Invitations
  class SendSms < BaseService
    include Rails.application.routes.url_helpers
    include Invitations::SmsContent

    def initialize(invitation:)
      @invitation = invitation
    end

    def call
      check_invitation_format!
      check_phone_number!
      send_sms
    end

    private

    def check_invitation_format!
      fail!("Envoi de SMS alors que le format est #{@invitation.format}") unless @invitation.format_sms?
    end

    def check_phone_number!
      fail!("Le téléphone doit être renseigné") if applicant.phone_number.blank?
      fail!("Le numéro de téléphone doit être un mobile") unless applicant.phone_number_is_mobile?
    end

    def send_sms
      return Rails.logger.info(content) unless Rails.env.production?

      SendTransactionalSms.call(phone_number_formatted: phone_number_formatted,
                                sender_name: sender_name, content: content)
    end

    def content
      if @invitation.reminder?
        send(:"content_for_#{@invitation.motif_category}_reminder")
      else
        send(:"content_for_#{@invitation.motif_category}")
      end
    end

    def phone_number_formatted
      applicant.phone_number_formatted
    end

    def number_of_days_to_accept_invitation
      @invitation.number_of_days_to_accept_invitation
    end

    def sender_name
      @invitation.invitation_parameters&.sms_sender_name || "Dept#{@invitation.department.number}"
    end

    def applicant
      @invitation.applicant
    end

    def organisation
      @invitation.organisations.first
    end
  end
end
