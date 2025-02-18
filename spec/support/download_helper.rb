# Inspired by https://dev.to/coorasse/test-downloaded-files-with-rspec-and-system-tests-55mn
module DownloadHelper
  TIMEOUT = 30
  PATH = Rails.root.join("tmp/downloads")

  def downloads
    Dir[PATH.join("*")]
  end

  def download
    downloads.first
  end

  def download_content(format: nil)
    wait_for_download
    case format
    when "pdf"
      content = File.read(download, mode: "rb")
      PDF::Reader.new(StringIO.new(content))
    else
      File.read(download)
    end
  end

  def wait_for_download
    Timeout.timeout(TIMEOUT) do
      sleep 0.1 until downloaded?
    end
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
