class MessagesConfiguration < ApplicationRecord
  SIGNATURE_ACCEPTED_FORMATS = %w[PNG JPG].freeze
  SIGNATURE_MIME_TYPES = [
    "image/png",
    "image/jpeg"
  ].freeze
  LOGO_TYPES = %w[department europe france_travail].freeze

  before_save :remove_blank_array_fields
  after_save :purge_signature_if_requested

  belongs_to :organisation
  has_one_attached :signature_image

  delegate :department, to: :organisation

  attr_accessor :remove_signature

  validates :sms_sender_name, length: { maximum: 11, message: "ne doit pas dépasser 11 caractères" },
                              format: { with: /\A[a-zA-Z0-9]+\z/,
                                        message: "ne doit contenir que des lettres et des chiffres" },
                              allow_nil: true

  validates :signature_image, max_size: 2.megabytes,
                              accepted_formats: { formats: SIGNATURE_ACCEPTED_FORMATS,
                                                  mime_types: SIGNATURE_MIME_TYPES },
                              allow_nil: true

  validates :displayed_logos, inclusion: { in: LOGO_TYPES }

  private

  def remove_blank_array_fields
    # We don't want blank signature_lines or direction_names in the invitations
    signature_lines&.compact_blank!
    direction_names&.compact_blank!
  end

  def purge_signature_if_requested
    signature_image.purge_later if remove_signature == "true" && signature_image.attached?
  end
end
