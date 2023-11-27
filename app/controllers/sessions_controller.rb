class SessionsController < ApplicationController
  skip_before_action :authenticate_agent!, only: [:create, :new]
  wrap_parameters false
  respond_to :json, only: :create

  include Agents::SignIn
  before_action :validate_session!, :retrieve_agent!, :mark_agent_as_logged_in!, :set_session_credentials,
                only: [:create]

  before_action :handle_inclusion_connect_logout, only: [:destroy], if: :logged_with_inclusion_connect?

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
    InclusionConnectClient.logout(session[:inclusion_connect_token_id])
  end

  def logged_with_inclusion_connect?
    session.dig(:rdv_solidarites, "inclusion_connected") == true
  end

  def handle_inclusion_connect_logout
    return if logout_inclusion_connect.success?

    flash[:error] = "Nous n'avons pas pu vous déconnecter d'Inclusion Connect. Contacter le support à l'adresse
                    <data.insertion@beta.gouv.fr> si le problème persiste."
    redirect_to root_path
  end
end
