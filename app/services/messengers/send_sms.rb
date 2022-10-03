module Messengers
  class SendSms < BaseService
    def initialize(sendable:, content:)
      @sendable = sendable
      @content = content
    end

     def call
      check_invitation_format!
      check_phone_number!
      send_sms
    end

    private

    def check_invitation_format!
      fail!("Envoi de SMS alors que le format est #{@sendable.format}") unless @sendable.format == "sms"
    end

    def check_phone_number!
      fail!("Le téléphone doit être renseigné") if @sendable.phone_number.blank?
      fail!("Le numéro de téléphone doit être un mobile") unless @sendable.phone_number_is_mobile?
    end

    def send_sms
      return Rails.logger.info(@content) unless Rails.env.production?

      SendTransactionalSms.call(phone_number_formatted: @sendable.phone_number_formatted,
                                sender_name: @sendable.sms_sender_name, content: @content)
    end
  end
end
