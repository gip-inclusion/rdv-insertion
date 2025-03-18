require 'mime/types'
require 'filemagic'

class UploadedFileSanitizer
  MAX_FILE_SIZE = 5 * 1024 * 1024 # 5MB
  ALLOWED_EXTENSIONS = %w[.jpg .png .pdf .xlsx .csv].freeze
  ALLOWED_MIME_TYPES = {
    ".jpg" => "image/jpeg",
    ".png" => "image/png",
    ".pdf" => "application/pdf",
    ".xlsx" => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    ".csv" => "text/csv"
  }.freeze

  def self.sanitize(uploaded_files)
    uploaded_files.map do |uploaded_file|
      new(uploaded_file).sanitize!
    end.compact
  end

  def initialize(uploaded_file)
    @uploaded_file = uploaded_file
  end

  def sanitize!
    return nil unless @uploaded_file.respond_to?(:original_filename)

    filename = @uploaded_file.original_filename
    extension = File.extname(filename).downcase
    mime_type = @uploaded_file.content_type
    file_size = @uploaded_file.size
    
    return nil unless valid_extension?(extension) && valid_mime_type?(extension, mime_type) && valid_content?(@uploaded_file.path, extension) && valid_size?(file_size)
    
    @uploaded_file
  end

  private

  def valid_extension?(extension)
    ALLOWED_EXTENSIONS.include?(extension)
  end

  def valid_mime_type?(extension, mime_type)
    ALLOWED_MIME_TYPES[extension] == mime_type
  end

  def valid_content?(file_path, extension)
    fm = FileMagic.new(:mime)
    detected_mime = fm.file(file_path)
    fm.close
    
    expected_mime = ALLOWED_MIME_TYPES[extension]
    detected_mime.start_with?(expected_mime)
  end

  def valid_size?(file_size)
    file_size <= MAX_FILE_SIZE
  end
end
