module AttachmentValidator
  # to be included, this concern need the following things in the model :
  # - a has_one_attached
  # - a attachment method (an alias for the name of the has_one_attached)
  # - a constant MAX_ATTACHMENT_SIZE
  # - a constant MIME_TYPES
  # - a constant ACCEPTED_FORMATS (an array of strings with the attachment extensions allowed by the MIME_TYPES )

  extend ActiveSupport::Concern

  def attachment
    raise NoMethodError
  end

  included do
    validate :attachment_size_validation, if: -> { attachment.present? }
    validate :attachment_format_validation, if: -> { attachment.present? }
  end

  private

  def attachment_size_validation
    return unless attachment.blob.byte_size > self.class::MAX_ATTACHMENT_SIZE

    # MAX_ATTACHMENT_SIZE must be in megabytes for the error message to be accurate
    errors.add(:base, "Le fichier est trop volumineux (#{self.class::MAX_ATTACHMENT_SIZE.to_s[0...-6]}mo maximum)")
  end

  def attachment_format_validation
    return if self.class::MIME_TYPES.include?(attachment.blob.content_type)

    errors.add(:base, "Seuls les formats #{self.class::ACCEPTED_FORMATS.join(', ')} sont acceptés.")
  end
end
