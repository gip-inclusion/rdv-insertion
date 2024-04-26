class SessionsController < ApplicationController
  skip_before_action :authenticate_agent!, only: [:create, :new]
  wrap_parameters false
  respond_to :json, only: :create

  include Agents::SignInWithRdvSolidarites
  before_action :validate_rdv_solidarites_credentials!, :retrieve_agent!, :mark_agent_as_logged_in!,
                only: [:create]

  before_action :handle_inclusion_connect_logout, only: [:destroy], if: :logged_with_inclusion_connect?

  def new; end

  def create
    set_session_credentials
    render json: { success: true, redirect_path: root_path }
  end

  def destroy
    clear_session
    flash[:notice] = "Déconnexion réussie"
    redirect_to root_path
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

  def handle_inclusion_connect_logout
    logout = InclusionConnectClient.logout(agent_session.inclusion_connect_token_id)
    return if logout.success?

    flash[:error] = "Nous n'avons pas pu vous déconnecter d'Inclusion Connect. Contacter le support à l'adresse
                    <rdv-insertion@beta.gouv.fr> si le problème persiste."
    redirect_to root_path
  end
end
