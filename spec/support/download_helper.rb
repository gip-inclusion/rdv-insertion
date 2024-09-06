# Inspired by https://dev.to/coorasse/test-downloaded-files-with-rspec-and-system-tests-55mn
module DownloadHelper
  TIMEOUT = 10
  PATH = Rails.root.join("tmp/downloads")

  def downloads
    Dir[PATH.join("*")]
  end

  def download
    downloads.first
  end

  def download_content(format: nil)
    format == "pdf" ? PDF::Reader.new(download) : File.read(download)
  end

  def wait_for_download
    Timeout.timeout(TIMEOUT) do
      Thread.pass until downloaded?
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
    FileUtils.rm_f(downloads)
  end
end
