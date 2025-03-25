class UploadedFileSanitizer
  MAX_FILE_SIZE = 5 * 1024 * 1024 # 5MB
  ALLOWED_EXTENSIONS = %w[.jpg .jpeg .png .pdf .xlsx .csv].freeze
  ALLOWED_MIME_TYPES = {
    ".jpg" => ["image/jpeg"],
    ".jpeg" => ["image/jpeg"],
    ".png" => ["image/png"],
    ".pdf" => ["application/pdf"],
    ".xlsx" => ["application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "application/zip"],
    ".csv" => ["text/csv"]
  }.freeze

  def self.sanitize_all(uploaded_files)
    uploaded_files.map do |uploaded_file|
      new(uploaded_file).sanitize
    end.compact
  end

  def initialize(uploaded_file)
    @uploaded_file = uploaded_file
  end

  def sanitize
    return nil unless @uploaded_file.respond_to?(:original_filename)

    if valid_extension?(extension) &&
       valid_mime_type?(extension, mime_type) &&
       valid_content?(@uploaded_file.path, extension) &&
       valid_size?(file_size)
      @uploaded_file
    else
      Sentry.capture_message("Invalid file upload", extra: {
                               filename:,
                               extension:,
                               mime_type:,
                               file_size:,
                               detected_content_type: detected_content_type(@uploaded_file.path)
                             })

      nil
    end
  end

  private

  def extension
    File.extname(filename).downcase
  end

  def filename
    @uploaded_file.original_filename
  end

  def mime_type
    @uploaded_file.content_type
  end

  def file_size
    @uploaded_file.size
  end

  def valid_extension?(extension)
    ALLOWED_EXTENSIONS.include?(extension)
  end

  def valid_mime_type?(extension, mime_type)
    ALLOWED_MIME_TYPES[extension].include?(mime_type)
  end

  def valid_content?(file_path, extension)
    ALLOWED_MIME_TYPES[extension].include?(detected_content_type(file_path))
  end

  def valid_size?(file_size)
    file_size <= MAX_FILE_SIZE
  end

  def detected_content_type(file_path)
    MimeMagic.by_magic(File.open(file_path))&.type
  end
end
