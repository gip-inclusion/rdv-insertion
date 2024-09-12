module NavigationHelper
  def structure_id_param
    department_level? ? { department_id: current_department_id } : { organisation_id: current_organisation_id }
  end

  #
  # Catches routes methods containing "structure" :
  # => it will replace structure with the current structure name and add the structure_id to the params
  #
  # Example : current structure is a Department with id 1
  #
  # structure_foo_path will generate a path scoped to the current structure
  #        executes => department_foo_path(department_id: 1)
  #        returns  => /departments/1/foo
  #
  def method_missing(method_name, params = {}, additional_params = {})
    return super unless method_name.to_s.match(/^(?=.*structure)(?=.*(path|url))/)

    params = { id: params } if params.is_a?(Integer)
    params_with_structure = { **params, **structure_id_param, **additional_params }
    route_name = method_name.to_s.gsub("structure", current_structure_type)

    send(route_name, params_with_structure)
  end

  def respond_to_missing?(method_name, include_private = false)
    method_name.to_s.match(/^(?=.*structure)(?=.*(path|url))/) || super
  end
end
