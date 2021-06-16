class SessionsController < ApplicationController
  PERMITTED_PARAMS = [:authenticity_token, :client, :uid, :access_token, { organisation_ids: [] }].freeze
  skip_before_action :authenticate_agent!, only: [:new, :create]
  wrap_parameters false

  def new; end

  def show
    respond_to do |format|
      format.json do
        render json: {
          session: {
            department_id: session[:department_id],
            rdv_solidarites: session[:rdv_solidarites]
          }
        }
      end
    end
  end

  def create
    if find_or_create_agent.success?
      set_session
      respond_to do |format|
        format.json { render json: { success: true, redirect_path: department_path(current_agent.department) } }
      end
    else
      respond_to do |format|
        format.json { render json: { success: false, errors: find_or_create_agent.errors } }
      end
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

  def set_session
    session[:agent_id] = find_or_create_agent.agent.id
    session[:rdv_solidarites] = {
      client: session_params[:client],
      uid: session_params[:uid],
      access_token: session_params[:access_token]
    }
  end

  def session_params
    params.permit(*PERMITTED_PARAMS)
  end
end
