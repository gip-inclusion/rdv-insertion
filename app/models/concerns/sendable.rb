module Sendable
  extend ActiveSupport::Concern

  delegate :email, :phone_number, :phone_number_formatted, :phone_number_is_mobile?,
           :address, :street_address, :zipcode_and_city,
           to: :applicant
  delegate :signature_lines, :sender_city, :help_address, :display_europe_logos, :direction_names,
           to: :messages_configuration, allow_nil: true

  def sms_sender_name
    messages_configuration&.sms_sender_name || "Dept#{applicant.department_number}"
  end

  def letter_sender_name
    messages_configuration.letter_sender_name || "le Conseil départemental"
  end
end
