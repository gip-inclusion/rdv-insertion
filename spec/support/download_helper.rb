module DownloadHelper
  TIMEOUT = 10
  PATH = Rails.root.join("tmp/downloads")

  def self.download_path
    test_env_number = ENV["TEST_ENV_NUMBER"].to_s.empty? ? "" : ENV["TEST_ENV_NUMBER"]
    PATH.join("process_#{test_env_number}")
  end

  def downloads
    Dir[DownloadHelper.download_path.join("*")]
  end

  def download
    downloads.first
  end

  def download_content(format: nil)
    format == "pdf" ? PDF::Reader.new(download) : File.read(download)
  end

  def wait_for_download
    Timeout.timeout(TIMEOUT) do
      sleep 0.1 until downloaded?
    end
  end

  def downloaded_content(format: nil)
    wait_for_download
    download_content(format:)
  end

  def downloaded?
    !downloading? && downloads.any?
  end

  def downloading?
    downloads.grep(/\.crdownload$/).any?
  end

  def clear_downloads
    FileUtils.rm_rf(DownloadHelper.download_path)
  end
end
