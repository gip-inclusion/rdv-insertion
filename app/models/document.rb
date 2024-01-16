class Document < ApplicationRecord
  belongs_to :organisation, optional: true
  belongs_to :department
  belongs_to :agent
  belongs_to :user

  enum document_type: {
    diagnostic: "diagnostic",
    contract: "contract"
  }

  has_one_attached :file

  validates :file,
            presence: true,
            blob: {
              content_type: [
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
              ],
              size_range: 1..(5.megabytes)
            }
end
