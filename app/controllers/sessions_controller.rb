class SessionsController < ApplicationController
  skip_before_action :authenticate_agent!, only: [:create, :new]
  wrap_parameters false
  respond_to :json, only: :create

  include Agents::SignIn
  before_action :validate_session!, :retrieve_agent!, :mark_agent_as_logged_in!, :set_session_credentials,
                only: [:create]

  def new; end

  def create
    render json: { success: true, redirect_path: session.delete(:agent_return_to) || organisations_path }
  end

  def destroy
    if session[:rdv_solidarites]["inclusion_connected"]
      InclusionConnectClient.logout(session[:ic_state], session[:ic_token])
    end
    clear_session
    flash[:notice] = "Déconnexion réussie"
    redirect_to root_path
  end

  private

  def clear_session
    session.delete(:agent_id)
    session.delete(:rdv_solidarites)
    @current_agent = nil
  end
end
