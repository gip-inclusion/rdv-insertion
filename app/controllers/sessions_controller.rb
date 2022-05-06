class SessionsController < ApplicationController
  skip_before_action :authenticate_agent!, only: [:new, :create]
  wrap_parameters false
  respond_to :json, only: :create

  include RdvSolidaritesSessionConcern
  include RdvSolidaritesAgentConcern
  before_action :validate_session!, :retrieve_agent_organisations!, :upsert_agent!, only: [:create]

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
    session[:agent_id] = upsert_agent.agent.id
    session[:rdv_solidarites] = {
      client: request.headers["client"],
      uid: request.headers["uid"],
      access_token: request.headers["access-token"]
    }
  end

  def clear_session
    session.delete(:agent_id)
    @current_agent = nil
  end
end
