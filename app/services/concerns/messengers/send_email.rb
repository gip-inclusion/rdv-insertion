module Messengers::SendEmail
  extend ActiveSupport::Concern

  included do
    before_call :verify_invitation_format!, :verify_email!
  end

  private

  def verify_invitation_format!
    fail!("Envoi d'un email alors que le format est #{sendable.format}") unless sendable.format == "email"
  end

  def verify_email!
    fail!("L'email doit être renseigné") if sendable.email.blank?
    return unless (sendable.email =~ URI::MailTo::EMAIL_REGEXP).nil?

    fail!("L'email renseigné ne semble pas être une adresse valable")
  end

  def sendable
    raise NotImplementedError
  end
end
