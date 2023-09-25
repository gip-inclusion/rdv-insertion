class ReferentAssignationsController < ApplicationController
  before_action :set_user, :set_department, :set_agents, only: [:index, :create, :destroy]
  before_action :set_agent, only: [:create, :destroy]

  def index; end

  def create
    @success = assign_referent.success?
    @errors = assign_referent.errors
    respond_to do |format|
      format.turbo_stream do
        if @success
          flash.now[:success] = "Le référent a bien été assigné"
        else
          flash.now[:error] = "Une erreur s'est produite lors de l'assignation du référent: #{@errors}"
        end
      end
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

  def set_department
    @department = policy_scope(Department).find(params[:department_id])
  end

  def set_agents
    @agents = Agent.joins(:organisations).where(
      organisations: @user.organisations.where(department_id: params[:department_id])
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
