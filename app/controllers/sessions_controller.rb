class SessionsController < ApplicationController
  skip_before_action :authenticate_agent!, only: [:create, :new]
  wrap_parameters false
  respond_to :json, only: :create

  include Agents::SignIn
  before_action :validate_credentials!, :retrieve_agent!, :mark_agent_as_logged_in!, :set_session_credentials,
                only: [:create]

  def new; end

  def create
    render json: { success: true, redirect_path: session.delete(:agent_return_to) || organisations_path }
  end

  def destroy
    logout_url = logged_with_inclusion_connect? ? logout_path_inclusion_connect : root_path
    clear_session
    flash[:notice] = "Déconnexion réussie"
    redirect_to logout_url, allow_other_host: true
  end

  private

  def logout_path_inclusion_connect
    InclusionConnectClient.logout_path(session[:inclusion_connect_token_id], session[:ic_state])
  end

  def logged_with_inclusion_connect?
    session.dig(:rdv_solidarites_credentials, "inclusion_connected") == true
  end
end
