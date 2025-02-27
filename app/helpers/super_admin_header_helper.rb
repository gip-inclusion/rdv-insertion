module SuperAdminHeaderHelper
  def super_admin_header_closed?
    cookies[:super_admin_header_closed] == "true"
  end
end
