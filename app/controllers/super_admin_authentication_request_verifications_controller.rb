class SuperAdminAuthenticationRequestVerificationsController < ApplicationController
  # Very strict rate limit for super admin verification - 3/min
  rate_limit_with_json_response limit: 3, period: 1.minute

  before_action :verify_super_admin
  before_action :set_super_admin_authentication_request, only: [:create]

  def new; end

  def create
    if @super_admin_authentication_request.verify(params[:token])
      redirect_to super_admins_root_path, notice: "Connexion Super Admin réussie"
    else
      flash.now[:alert] = @super_admin_authentication_request.errors.full_messages.first
      render :new
    end
  end

  private

  def verify_super_admin
    redirect_to root_path, alert: "Vous n'avez pas accès à cette page" unless current_agent.super_admin?
  end

  def set_super_admin_authentication_request
    @super_admin_authentication_request = current_agent.last_super_admin_authentication_request
  end
end
