class Document < ApplicationRecord
  belongs_to :department
  belongs_to :agent
  belongs_to :user

  enum document_type: {
    diagnostic: "diagnostic",
    contract: "contract"
  }

  has_one_attached :file

  validates :file, presence: true
  validate :file_format_validation

  def file_format_validation
    if file.blob.byte_size > 5.megabytes
      file.purge
      errors.add(:base, "Le fichier est trop volumineux (5mo maximum).")
    elsif [
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
    ].exclude?(file.blob.content_type)
      file.purge
      errors.add(:base, "Seuls les formats PDF, JPG, PNG, ODT, DOCX, XLSX, PPT, DOC et ZIP sont acceptés.")
    end
  end
end
