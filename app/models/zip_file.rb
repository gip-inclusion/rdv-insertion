require "zip"

class ZipFile
  attr_reader :data, :initial_filename

  def initialize(data, initial_filename)
    @data = data
    @initial_filename = initial_filename
  end

  def zip
    temp_path = Rails.root.join("tmp", SecureRandom.uuid + initial_filename)
    File.write(temp_path, data)

    @temp_zip_path = Rails.root.join("tmp", "#{SecureRandom.uuid}-#{initial_filename}.zip")
    Zip::File.open(@temp_zip_path, Zip::File::CREATE) do |zipfile|
      zipfile.add(initial_filename, temp_path)
    end

    yield(self)
  ensure
    FileUtils.rm_f(temp_path)
    FileUtils.rm_f(@temp_zip_path)
  end

  def read
    File.read(@temp_zip_path)
  end

  def filename
    "#{initial_filename}.zip"
  end

  def mime_type
    "application/zip"
  end
end
