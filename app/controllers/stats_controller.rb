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
    @department_number = params[:department_number]
    return if @department_number.blank?

    @applicants = Department.find_by(number: @department_number).applicants
    @agents = Department.find_by(number: @department_number).agents
    @invitations = Department.find_by(number: @department_number).invitations
    @rdvs = Department.find_by(number: @department_number).rdvs
    @organisations = Department.find_by(number: @department_number).organisations
  end
end
