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
    case format
    when "pdf"
      pdf_file = download
      pdf_double = Object.new
      pdf_double.define_singleton_method(:pages) do
        [OpenStruct.new(text: File.read(pdf_file))]
      end
      pdf_double
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

  def stub_pdf_service(sample_text:)
    encoded_content = Base64.encode64(sample_text)
    stub_request(:post, %r{http://pdf-service.example.com/generate.*})
      .to_return(
        status: 200,
        headers: { "Content-Type" => "application/json" },
        body: encoded_content
      )
  end
end
