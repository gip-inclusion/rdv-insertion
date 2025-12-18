class MessagesConfiguration < ApplicationRecord
  LOGO_TYPES = %w[department europe france_travail].freeze

  has_attached_image :signature_image

  belongs_to :organisation

  before_save :remove_blank_array_fields

  delegate :department, to: :organisation

  validates :sms_sender_name, length: { maximum: 11, message: "ne doit pas dépasser 11 caractères" },
                              format: { with: /\A[a-zA-Z0-9]+\z/,
                                        message: "ne doit contenir que des lettres et des chiffres" },
                              allow_nil: true

  validates :logos_to_display, inclusion: { in: LOGO_TYPES }

  nullify_blank :sms_sender_name, :letter_sender_name, :sender_city, :help_address

  def effective_sms_sender_name
    sms_sender_name.presence || default_sms_sender_name
  end

  def effective_letter_sender_name
    letter_sender_name.presence || default_letter_sender_name
  end

  def effective_sender_city
    sender_city.presence || default_sender_city
  end

  def effective_direction_names
    direction_names.presence || default_direction_names
  end

  def effective_signature_lines
    signature_lines.presence || default_signature_lines
  end

  def default_sms_sender_name
    "Dept#{department.number}"
  end

  def default_letter_sender_name
    "le Conseil départemental"
  end

  def default_sender_city
    department.capital
  end

  def default_direction_names
    [organisation.name]
  end

  def default_signature_lines
    ["Le département #{I18n.t("with_prefix.#{department.pronoun}", name: department.name)}"]
  end

  def fallback_value_for(attribute)
    send("default_#{attribute}")
  end

  def logos_to_display_names
    logos_to_display.map do |logo|
      I18n.t("activerecord.attributes.messages_configuration.logo_types.#{logo}")
    end.join(", ")
  end

  private

  def remove_blank_array_fields
    # We don't want blank signature_lines or direction_names in the invitations
    signature_lines&.compact_blank!
    direction_names&.compact_blank!
  end
end
