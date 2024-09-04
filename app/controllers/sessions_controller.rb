class SessionsController < ApplicationController
  skip_before_action :authenticate_agent!, only: [:create, :new]
  wrap_parameters false
  respond_to :json, only: :create

  include Agents::SignInWithRdvSolidarites
  before_action :validate_rdv_solidarites_credentials!, :retrieve_agent!, :mark_agent_as_logged_in!,
                :set_agent_return_to_url,
                only: [:create]

  def new; end

  def create
    set_session_credentials
    render json: { success: true, redirect_path: @agent_return_to_url || root_path }
  end

  def destroy
    agent_connect_token = session.dig(:agent_auth, :agent_connect_id_token)
    clear_session
    flash[:notice] = "Déconnexion réussie"

    if agent_connect_token
      agent_connect_client = AgentConnect::Client::Logout.new(agent_connect_token)
      redirect_to agent_connect_client.agent_connect_logout_url(root_url), allow_other_host: true
    else
      redirect_to root_path
    end
  end

  private

  def set_session_credentials
    clear_session
    timestamp = Time.zone.now.to_i
    session[:agent_auth] = {
      id: authenticated_agent.id,
      created_at: timestamp,
      origin: "sign_in_form",
      signature: authenticated_agent.sign_with(timestamp)
    }
  end

  def set_agent_return_to_url
    @agent_return_to_url = session[:agent_return_to]
  end
end
