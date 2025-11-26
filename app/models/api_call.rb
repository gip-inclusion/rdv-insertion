class ApiCall < ApplicationRecord
  belongs_to :agent, optional: true

  scope :today, -> { where(created_at: Time.current.all_day) }
  scope :by_endpoint, ->(action) { where(action_name: action) }
  scope :by_controller, ->(controller) { where(controller_name: controller) }

  def self.usage_stats
    group(:controller_name, :action_name).count
  end

  def self.usage_stats_by_day
    group_by_day(:created_at).count
  end

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
