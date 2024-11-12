class ParcoursDocument < ApplicationRecord
  MAX_SIZE = 5.megabytes

  ACCEPTED_FORMATS = %w[PDF JPG PNG ODT DOC DOCX XLSX PPT ZIP].freeze

  MIME_TYPES = [
    "application/pdf",
    "image/jpeg",
    "image/png",
    "application/vnd.oasis.opendocument.text",
    "application/vnd.oasis.opendocument.spreadsheet",
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    "application/vnd.openxmlformats-officedocument.presentationml.presentation",
    "application/vnd.openxmlformats-officedocument.presentationml.slideshow",
    "application/vnd.openxmlformats-officedocument.presentationml.slide",
    "application/vnd.ms-powerpoint",
    "application/msword",
    "application/vnd.ms-excel",
    "application/zip"
  ].freeze

  belongs_to :department
  belongs_to :agent, optional: true
  belongs_to :user

  has_one_attached :file

  validates :file, presence: true, max_size: MAX_SIZE,
                   accepted_formats: { formats: ACCEPTED_FORMATS, mime_types: MIME_TYPES }
end
