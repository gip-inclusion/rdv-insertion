module CguHelper
  def most_recent_cgu_version
    cgu_versions.first[1]
  end

  def cgu_versions
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
    cgu_versions.find { |_, v| v == version }
  end
end
