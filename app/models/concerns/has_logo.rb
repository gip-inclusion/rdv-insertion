module HasLogo
  extend ActiveSupport::Concern

  MAX_ATTACHMENT_SIZE = 2.megabytes

  ACCEPTED_FORMATS = %w[PNG JPG].freeze

  MIME_TYPES = [
    "image/png",
    "image/jpeg"
  ].freeze

  included do
    include AttachmentValidator

    has_one_attached :logo

    alias attachment logo
  end
end
