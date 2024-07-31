module NavigationHelper
  def structure_id_param
    department_level? ? { department_id: current_department_id } : { organisation_id: current_organisation_id }
  end

  def method_missing(method_name, params = {}, additional_params = {})
    if method_name.to_s.ends_with?("_with_structure")
      send(method_name.to_s.gsub("_with_structure", ""), { **params, **structure_id_param })
    elsif method_name.to_s.include?("structure")
      params = { id: params } if params.is_a?(Integer)

      send(
        method_name.to_s.gsub("structure", current_structure_type),
        {
          **structure_id_param,
          **params,
          **additional_params
        }
      )
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    method_name.to_s.include?("structure") || super
  end
end
