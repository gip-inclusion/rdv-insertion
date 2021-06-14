class SessionsController < ApplicationController
  PERMITTED_PARAMS = [:department_id, :client, :uid, :access_token].freeze
  skip_before_action :authenticate_user!, only: [:new, :create]

  def new
    @department_id = department_id
  end

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
    set_session
    respond_to do |format|
      format.json { render json: { success: true, redirect_path: department_path(department_id) } }
    end
  end

  def destroy
    clear_session
    flash[:notice] = "Déconnexion réussie"
    redirect_to root_path
  end

  private

  def session_params
    params.permit(*PERMITTED_PARAMS)
  end

  def set_session
    session[:department_id] = department_id
    session[:rdv_solidarites] = {
      client: session_params[:client],
      uid: session_params[:uid],
      access_token: session_params[:access_token]
    }
  end
end
