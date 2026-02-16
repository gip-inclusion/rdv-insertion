module Sendable
  extend ActiveSupport::Concern

  delegate :email, :phone_number, :phone_number_is_mobile?, :phone_number_is_french?,
           :address, :parsed_street_address, :parsed_post_code_and_city,
           to: :user
  delegate :signature_image, :help_address, :logos_to_display,
           to: :messages_configuration

  def sms_sender_name
    messages_configuration.effective_sms_sender_name
  end

  def letter_sender_name
    messages_configuration.effective_letter_sender_name
  end

  def sender_city
    messages_configuration.effective_sender_city
  end

  def direction_names
    messages_configuration.effective_direction_names
  end

  def signature_lines
    messages_configuration.effective_signature_lines
  end
end
