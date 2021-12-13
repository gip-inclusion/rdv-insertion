class StatsController < ApplicationController
  skip_before_action :authenticate_agent!, only: [:index]

  def index
    collect_datas
    filter_stats_by_department
    @stats = Stat.new(applicants: @applicants, agents: @agents, invitations: @invitations,
                      rdvs: @rdvs, organisations: @organisations)
  end

  private

  def collect_datas
    @applicants = Applicant.all
    @agents = Agent.all
    @invitations = Invitation.all
    @rdvs = Rdv.all
    @organisations = Organisation.all
  end

  def filter_stats_by_department
    return if params[:department_number].blank?

    @department = Department.find_by(number: params[:department_number])
    @applicants = @department.applicants
    @agents = @department.agents
    @invitations = @department.invitations
    @rdvs = @department.rdvs
    @organisations = @department.organisations
    @display_all_stats = !@organisations.all?(&:notify_applicant?)
  end
end
