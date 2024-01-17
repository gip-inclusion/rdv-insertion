require "zip"

class CompressFile < BaseService
  attr_reader :data, :filename

  def initialize(data, filename)
    @data = data
    @filename = filename
  end

  def call
    temp_path = Rails.root.join("tmp", SecureRandom.uuid + filename)
    File.write(temp_path, data)

    @temp_zip_path = Rails.root.join("tmp", "#{SecureRandom.uuid}-#{filename}.zip")
    Zip::File.open(@temp_zip_path, Zip::File::CREATE) do |zipfile|
      zipfile.add(filename, temp_path)
    end

    yield(self)
  ensure
    FileUtils.rm_f(temp_path)
    FileUtils.rm_f(@temp_zip_path)
  end

  def read
    File.read(@temp_zip_path)
  end

  def mime_type
    "application/zip"
  end
end
