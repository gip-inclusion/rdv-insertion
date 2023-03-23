class SessionsController < ApplicationController
  skip_before_action :authenticate_agent!, only: [:create, :new]
  wrap_parameters false
  respond_to :json, only: :create

  include Agents::SignIn
  before_action :validate_session!, :retrieve_agent!, :mark_agent_as_logged_in!, :set_session_credentials,
                only: [:create]

  before_action :logout_inclusion_connect, if: :logged_with_inclusion_connect

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
    InclusionConnectClient.logout(session[:ic_token])
    # TODO handle errors with flash
  end

  def clear_session
    session.delete(:agent_id)
    session.delete(:rdv_solidarites)
    @current_agent = nil
  end

  def logged_with_inclusion_connect
    return false if session.dig(:rdv_solidarites, "inclusion_connected").nil?

    session[:rdv_solidarites]["inclusion_connected"]
  end
end
