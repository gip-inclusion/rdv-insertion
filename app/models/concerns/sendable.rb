module Sendable
  extend ActiveSupport::Concern

  delegate :email, :phone_number, :phone_number_is_mobile?,
           :address, :parsed_street_address, :parsed_post_code_and_city,
           to: :user
  delegate :signature_lines, :signature_image, :sender_city, :help_address, :display_europe_logos,
           :display_department_logo, :display_france_travail_logo, :direction_names,
           to: :messages_configuration, allow_nil: true

  def sms_sender_name
    messages_configuration&.sms_sender_name || "Dept#{department.number}"
  end

  def letter_sender_name
    messages_configuration&.letter_sender_name || "le Conseil départemental"
  end
end
