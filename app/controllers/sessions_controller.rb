class SessionsController < ApplicationController
  skip_before_action :authenticate_agent!, only: [:new, :create]
  wrap_parameters false
  respond_to :json, only: :create

  include RdvSolidaritesSessionConcern
  before_action :validate_session!, only: [:create]

  def new; end

  def create
    return render_cannot_retrieve_organisations unless retrieve_organisations.success?

    if find_or_create_agent.success?
      set_session_credentials
      render json: { success: true, redirect_path: session.delete(:agent_return_to) || organisations_path }
    else
      render json: { success: false, errors: find_or_create_agent.errors }
    end
  end

  def destroy
    clear_session
    flash[:notice] = "Déconnexion réussie"
    redirect_to root_path
  end

  private

  def find_or_create_agent
    @find_or_create_agent ||= FindOrCreateAgent.call(
      email: request.headers["uid"], organisation_ids: retrieve_organisations.organisations.map(&:id)
    )
  end

  def render_cannot_retrieve_organisations
    render json: { success: false, errors: retrieve_organisations.errors }, status: :unprocessable_entity
  end

  def set_session_credentials
    session[:agent_id] = find_or_create_agent.agent.id
    session[:rdv_solidarites] = {
      client: request.headers["client"],
      uid: request.headers["uid"],
      access_token: request.headers["access_token"]
    }
  end

  def retrieve_organisations
    @retrieve_organisations ||= RdvSolidaritesApi::RetrieveOrganisations.call(
      rdv_solidarites_session: rdv_solidarites_session
    )
  end

  def clear_session
    session.delete(:agent_id)
    @current_agent = nil
  end
end
