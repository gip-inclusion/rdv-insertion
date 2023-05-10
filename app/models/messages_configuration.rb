class MessagesConfiguration < ApplicationRecord
  before_save :remove_blank_array_fields

  belongs_to :organisation
  validates :sms_sender_name, length: { maximum: 11, message: "ne doit pas dépasser 11 caractères" },
                              format: { with: /\A[a-zA-Z0-9]+\z/,
                                        message: "ne doit contenir que des lettres et des chiffres" },
                              allow_nil: true

  private

  def remove_blank_array_fields
    # We don't want blank signature_lines or direction_names in the invitations
    signature_lines&.compact_blank!
    direction_names&.compact_blank!
  end
end
