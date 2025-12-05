module HasLogo
  extend ActiveSupport::Concern
  ACCEPTED_FORMATS = %w[PNG JPG].freeze

  MIME_TYPES = [
    "image/png",
    "image/jpeg"
  ].freeze

  included do
    attr_accessor :remove_logo

    has_one_attached :logo
    validates :logo, max_size: 2.megabytes,
                     accepted_formats: { formats: ACCEPTED_FORMATS, mime_types: MIME_TYPES }

    after_save :purge_logo_if_requested
  end

  private

  def purge_logo_if_requested
    logo.purge_later if remove_logo == "true" && logo.attached?
  end
end
