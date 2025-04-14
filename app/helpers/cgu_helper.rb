module CguHelper
  def most_recent_cgu_version
    cgus_versions.first[1]
  end

  def cgus_versions
    Rails.root
         .glob("app/views/website/static_pages/cgus_versions/*.html.erb")
         .sort
         .reverse
         .map do |file|
      version = File.basename(file, ".html.erb").sub(/^_/, "")
      date = Date.strptime(version, "%Y_%m_%d")
      [date, version]
    end
  end

  def cgu_version_exists?(version)
    cgus_versions.find { |_, v| v == version }
  end
end
