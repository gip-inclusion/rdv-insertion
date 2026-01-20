class SuperAdminAuthenticationRequestsController < ApplicationController
  # Very strict rate limit for super admin authentication - 3/min
  rate_limit_with_json_response limit: ENV.fetch("RATE_LIMIT_SUPER_ADMIN_AUTH", ENV["RATE_LIMIT_DEFAULT"]).to_i,
                                period: 1.minute

  before_action :verify_super_admin

  def create
    current_agent.generate_and_send_super_admin_authentication_request!
    flash[:success] = "Un nouveau code de vérification a été envoyé à l'adresse email #{current_agent.email}."
    redirect_to new_super_admin_authentication_request_verification_path
  end

  private

  def verify_super_admin
    redirect_to root_path, alert: "Vous n'avez pas accès à cette page" unless current_agent.super_admin?
  end
end
