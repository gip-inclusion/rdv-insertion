class ApiCall < ApplicationRecord
  belongs_to :agent, optional: true

  # Theses methods are used in console only

  def self.used_endpoints
    distinct.pluck(:controller_name, :action_name).to_set
  end

  def self.unused_endpoints
    defined_endpoints - used_endpoints
  end

  def self.defined_endpoints
    Rails.application.routes.routes
         .select { |route| route.defaults[:controller]&.start_with?("api/v1/") }
         .to_set { |route| endpoint_from_route(route) }
  end

  def self.endpoint_from_route(route)
    controller = route.defaults[:controller].delete_prefix("api/v1/")
    action = route.defaults[:action]
    [controller, action]
  end
end
