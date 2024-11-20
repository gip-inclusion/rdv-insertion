module CguHelper
  def current_cgu_partial
    "cgus/#{current_cgu_partial_name}"
  end

  def current_cgu_partial_name
    directory = Rails.root.join("app/views/cgus")
    partials = Dir.entries(directory).select { |file| file.match(/^_\d{8}_/) }

    return nil if partials.empty?

    latest_partial = partials.max_by { |file| file.split("_").second.to_i }
    latest_partial.sub(/^\d{8}_/, "").sub(".html.erb", "").sub("_", "")
  end

  def current_cgu_date
    Date.strptime(current_cgu_partial_name, "%Y%m%d")
  end

  def should_accept_cgu?
    return false if current_agent.nil?
    return false if agent_impersonated?

    return true if current_agent.cgu_accepted_at.nil?

    current_agent.cgu_accepted_at < current_cgu_date
  end
end
