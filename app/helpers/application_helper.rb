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
end
