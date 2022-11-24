class AgentsApplicantsController < ApplicationController
  before_action :set_applicant, :set_department, :set_agents, only: [:new, :create]
  before_action :set_agent, only: [:create]

  def new; end

  def create
    assign_agent_to_applicant
    @success = true
  rescue ActiveRecord::ActiveRecordError => e
    @success = false
    Sentry.capture_exception(e)
  end

  private

  def agents_applicants_params
    params.require(:agents_applicant).permit(:agent_id)
  end

  def set_applicant
    @applicant = policy_scope(Applicant).find(params[:applicant_id])
    authorize @applicant
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
    ).distinct
  end

  def assign_agent_to_applicant
    @applicant.agents = [@agent]
  end
end
