module ApplicationHelper
  def alert_class_for(type)
    case type
    when :success
      "alert-success"
    when :alert
      "alert-warning"
    when :error
      "alert-danger"
    when :notice
      "alert-info"
    else
      alert.to_s
    end
  end

  def component_name_for_department(department_name)
    department_name.parameterize.capitalize
  end

  def asset_compiled?(asset_path)
    Webpacker.manifest.lookup(asset_path).present?
  end

  def image_compiled?(image_path)
    asset_compiled?("media/images/#{image_path}")
  end

  def show_login_button?
    !logged_in? && controller_name.include?("static_pages")
  end

  def show_guide_banner?
    show_login_button?
  end
end
