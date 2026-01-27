module CguHelper
  def most_recent_cgu_version
    sorted_cgu_versions.first
  end

  def sorted_cgu_versions
    Rails.root
         .glob("app/views/website/static_pages/cgus_versions/*.html.erb")
         .sort
         .reverse
         .map do |file|
           File.basename(file, ".html.erb").sub(/^_/, "")
    end
  end

  def cgu_version_exists?(version)
    sorted_cgu_versions.find { |v| v == version }
  end

  def cgu_version_date(version)
    l(Date.strptime(version, "%Y_%m_%d"), format: :long)
  end
end
