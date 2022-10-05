module Sendable
  extend ActiveSupport::Concern

  included do
    delegate :email, :phone_number, :phone_number_formatted, :phone_number_is_mobile?,
             to: :applicant
    delegate :signature_lines, :sms_sender_name, to: :messages_configuration
  end

  def sms_sender_name
    sms_sender_name || "Dept#{applicant.department_number}"
  end
end
