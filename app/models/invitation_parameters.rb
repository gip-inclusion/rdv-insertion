class InvitationParameters < ApplicationRecord
  has_many :organisations, dependent: :nullify

  validates :sms_sender_name, length: { maximum: 11, message: "ne doit pas dépasser 11 caractères" },
                              format: { with: /\A[a-zA-Z0-9]+\z/,
                                        message: "ne doit contenir que des lettres et des chiffres" },
                              allow_nil: true
end
