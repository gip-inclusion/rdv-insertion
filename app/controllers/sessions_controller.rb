class SessionsController < ApplicationController
  skip_before_action :authenticate_agent!, only: [:create, :new]
  wrap_parameters false
  respond_to :json, only: :create

  include Agents::SignIn
  before_action :validate_session!, :retrieve_agent!, :mark_agent_as_logged_in!, :set_session_credentials,
                only: [:create]

  before_action :logout_inclusion_connect, if: session[:rdv_solidarites]["inclusion_connected"]

  def new; end

  def create
    render json: { success: true, redirect_path: session.delete(:agent_return_to) || organisations_path }
  end

  def destroy
    clear_session
    flash[:notice] = "Déconnexion réussie"
    redirect_to root_path
  end

  private

  def logout_inclusion_connect
    InclusionConnectClient.logout(session[:ic_state], session[:ic_token])
    render flash error

  end

  def clear_session
    session.delete(:agent_id)
    session.delete(:rdv_solidarites)
    @current_agent = nil
  end
end
