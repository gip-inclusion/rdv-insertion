class SessionsController < ApplicationController
  PERMITTED_PARAMS = [:authenticity_token, :client, :uid, :access_token, { organisation_ids: [] }].freeze
  skip_before_action :authenticate_agent!, only: [:new, :create]
  wrap_parameters false
  respond_to :json, only: :create

  def new; end

  def create
    return render_invalid_session unless rdv_solidarites_session_valid?

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
      email: session_params[:uid], organisation_ids: session_params[:organisation_ids]
    )
  end

  def created_agent
    find_or_create_agent.agent
  end

  def set_session_credentials
    session[:agent_id] = created_agent.id
    session[:rdv_solidarites] = {
      client: session_params[:client],
      uid: session_params[:uid],
      access_token: session_params[:access_token]
    }
  end

  def rdv_solidarites_session_valid?
    RdvSolidaritesSession.new(
      uid: session_params[:uid],
      client: session_params[:client],
      access_token: session_params[:access_token]
    ).valid?
  end

  def render_invalid_session
    render json: { success: false, errors: ["La session RDV-Solidarités n'est pas valide"] }
  end

  def clear_session
    session.delete(:agent_id)
    @current_agent = nil
  end

  def session_params
    params.permit(*PERMITTED_PARAMS)
  end
end
