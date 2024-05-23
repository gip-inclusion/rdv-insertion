module PolicyHelper
  def authorized_all?(resources, action)
    resources.all? { |resource| policy(resource).send(:"#{action}?") }
  end

  def authorized_any?(resources, action)
    resources.any? { |resource| policy(resource).send(:"#{action}?") }
  end

  def authorize_all(resources, action)
    resources.each { |resource| authorize(resource, :"#{action}?") }
  end
end
