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
    respond_to do |format|
      format.json do
        render json: { success: true, redirect_path: @agent_return_to_url || root_path }
      end

      format.html do
        flash[:success] = "Connexion réussie"
        redirect_to @agent_return_to_url || root_path
      end
    end
  end

  def destroy
    # TODO: trouver un moyen de déconnecter de RDV Solidarités si on s'en sert pour l'oauth. Actuellement il faut ajouter une route et gérer le header de Allow-Origin
    clear_session
    flash[:notice] = "Déconnexion réussie"
    redirect_to root_path
  end

  private

  def set_session_credentials
    clear_session

    if request.env['omniauth.auth']
      session[:rdv_solidarites_oauth_token] = request.env['omniauth.auth']['credentials']['token']
    end

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
