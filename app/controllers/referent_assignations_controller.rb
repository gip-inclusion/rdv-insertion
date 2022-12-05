class ReferentAssignationsController < ApplicationController
  before_action :set_applicant, :set_department, :set_agents, only: [:index, :create, :destroy]
  before_action :set_agent, only: [:create, :destroy]

  def index; end

  def create
    @success = assign_referent.success?
    @errors = assign_referent.errors
  end

  def destroy
    @success = remove_referent.success?
    @errors = remove_referent.errors
  end

  private

  def agents_applicants_params
    params.require(:referent_assignation).permit(:agent_id)
  end

  def set_applicant
    @applicant = policy_scope(Applicant).includes(:agents).find(params[:applicant_id])
  end

  def set_department
    @department = policy_scope(Department).find(params[:department_id])
  end

  def set_agent
    @agent = @agents.find(agents_applicants_params[:agent_id])
  end

  def set_agents
    @agents = Agent.joins(:organisations).where(
      organisations: @applicant.organisations.where(department_id: params[:department_id])
    ).distinct.order(:email)
    @agents = @agents.not_betagouv if production_env?
  end

  def assign_referent
    @assign_referent ||= Applicants::AssignReferent.call(
      applicant: @applicant, agent: @agent, rdv_solidarites_session: rdv_solidarites_session
    )
  end

  def remove_referent
    @remove_referent ||= Applicants::RemoveReferent.call(
      applicant: @applicant, agent: @agent, rdv_solidarites_session: rdv_solidarites_session
    )
  end
end
