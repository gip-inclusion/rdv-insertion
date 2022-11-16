class SessionsController < ApplicationController
  skip_before_action :authenticate_agent!
  wrap_parameters false
  respond_to :json, only: :create

  include RdvSolidaritesSessionConcern
  include RdvSolidaritesAgentConcern
  before_action :validate_session!, :retrieve_agent!, :mark_as_logged_in!, only: [:create]

  def new; end

  def create
    set_session_credentials
    render json: { success: true, redirect_path: session.delete(:agent_return_to) || organisations_path }
  end

  def destroy
    clear_session
    flash[:notice] = "Déconnexion réussie"
    redirect_to root_path
  end

  private

  def set_session_credentials
    session[:agent_id] = current_agent.id
    session[:rdv_solidarites] = {
      client: request.headers["client"],
      uid: request.headers["uid"],
      access_token: request.headers["access-token"]
    }
  end

  def clear_session
    session.delete(:agent_id)
    session.delete(:rdv_solidarites)
    @current_agent = nil
  end
end
