module MatomoHelper
  def matomo_page_url
    current_path = request.path
    route_info = Rails.application.routes.recognize_path(current_path)
    matching_route = find_matching_route(route_info, current_path)

    return current_path unless matching_route

    route_pattern_without_ids(matching_route)
  rescue ActionController::RoutingError, NoMethodError
    current_path
  end

  private

  def find_matching_route(route_info, path)
    Rails.application.routes.routes.find do |route|
      route.defaults[:controller] == route_info[:controller] &&
        route.defaults[:action] == route_info[:action] &&
        route.path.match?(path)
    end
  end

  def route_pattern_without_ids(route)
    route.path.spec.to_s.gsub("(.:format)", "")
  end
end
