class ReferentAssignationsController < ApplicationController
  before_action :set_department, :set_user, :set_agents, only: [:index, :create, :destroy]
  before_action :verify_user_is_sync_with_rdv_solidarites, only: [:create]
  before_action :set_agent, only: [:create, :destroy]

  def index; end

  def create
    @success = assign_referent.success?
    @errors = assign_referent.errors
    respond_to do |format|
      format.turbo_stream { render_result_in_flash }
      format.json do
        render json: { success: @success, errors: @errors }, status: @success ? :ok : :unprocessable_entity
      end
    end
  end

  def destroy
    if remove_referent.success?
      flash.now[:success] = "Le référent a bien été retiré"
    else
      flash.now[:error] = "Une erreur s'est produite lors du détachement du référent: #{remove_referent.errors}"
    end
  end

  private

  def render_result_in_flash
    if @success
      flash.now[:success] = "Le référent a bien été assigné"
    else
      flash.now[:error] = "Une erreur s'est produite lors de l'assignation du référent: #{@errors}"
    end
  end

  def referent_assignation_params
    params.require(:referent_assignation).permit(:agent_id, :user_id, :agent_email)
  end

  def user_id
    params[:user_id] || referent_assignation_params[:user_id]
  end

  def agent_id
    referent_assignation_params[:agent_id]
  end

  def agent_email
    referent_assignation_params[:agent_email]
  end

  def set_user
    @user = policy_scope(User).includes(:referents).find(user_id)
  end

  def verify_user_is_sync_with_rdv_solidarites
    sync_user_with_rdv_solidarites(@user) if @user.rdv_solidarites_user_id.nil?
  end

  def set_department
    @department = policy_scope(Department).find(current_department_id)
  end

  def set_agents
    @agents = Agent.joins(:organisations).where(
      organisations: @user.organisations.where(department: @department)
    ).distinct.order(:email)
    @agents = @agents.not_betagouv if production_env?
  end

  def assign_referent
    @assign_referent ||= Users::AssignReferent.call(
      user: @user, agent: @agent, rdv_solidarites_session: rdv_solidarites_session
    )
  end

  def remove_referent
    @remove_referent ||= Users::RemoveReferent.call(
      user: @user, agent: @agent, rdv_solidarites_session: rdv_solidarites_session
    )
  end

  def set_agent
    @agent =
      if agent_id.present?
        @agents.find(agent_id)
      elsif agent_email.present?
        @agents.find_by!(email: agent_email)
      else
        raise ActiveRecord::RecordNotFound
      end
  end
end
