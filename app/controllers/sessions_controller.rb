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
    if logged_with_inclusion_connect?
      if logout_inclusion_connect
        flash[:notice] = "Déconnexion réussie"
      else
        flash[:error] = "Nous n'avons pas pu vous déconnecter d'Inclusion Connect. Contacter le support à l'adresse \
                        <data.insertion@beta.gouv.fr> si le problème persiste."
        return redirect_to root_path
      end
    else
      flash[:notice] = "Déconnexion réussie"
    end

    clear_session

    redirect_to root_path
  end

  private

  def logout_inclusion_connect
    response = Client::InclusionConnect.logout(session[:inclusion_connect_token_id])
    return false unless response.success?

    true
  end

  def clear_session
    session.delete(:inclusion_connect_token_id)
    session.delete(:ic_state)
    session.delete(:agent_id)
    session.delete(:rdv_solidarites)
    @current_agent = nil
  end

  def logged_with_inclusion_connect?
    session.dig(:rdv_solidarites, "inclusion_connected") == true
  end
end
