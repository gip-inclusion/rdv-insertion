module NavigationHelper
  def structure_id_param
    department_level? ? { department_id: Current.department_id } : { organisation_id: Current.organisation_id }
  end

  # enables to call methods like structure_user_path(id: user.id) with structure being the current organisation
  # or the current department
  def method_missing(method_name, **params)
    method_name = method_name.to_s
    return super unless method_name.include?("structure")

    send(method_name.gsub("structure", Current.structure_type), **params.merge(structure_id_param))
  end

  def respond_to_missing?(method_name, include_private = false)
    method_name.to_s.include?("structure") || super
  end
end
