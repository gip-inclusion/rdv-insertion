class StatsController < ApplicationController
  skip_before_action :authenticate_agent!, only: [:index]

  def index
    collect_datas
    filter_stats_by_department
    @stats = Stat.new(applicants: @applicants, agents: @agents, invitations: @invitations,
                      organisations: @organisations, rdvs: @rdvs)
  end

  private

  def collect_datas
    @rdvs = Rdv.all
    @applicants = Applicant.all
    @invitations = Invitation.all
    @agents = Agent.all
    @organisations = Organisation.all
  end

  def filter_stats_by_department
    @department_number = params[:department]
    return if @department_number.blank?

    @applicants = @applicants.joins(organisations: :department)
                             .where(organisations: { departments: { number: @department_number } })
    @agents = @agents.joins(organisations: :department)
                     .where(organisations: { departments: { number: @department_number } })
    @invitations = @invitations.joins(organisation: :department)
                               .where(organisation: { departments: { number: @department_number } })
    @rdvs = @rdvs.joins(organisation: :department)
                 .where(organisations: { departments: { number: @department_number } })
    @organisations = @organisations.joins(:department)
                                   .where(departments: { number: @department_number })
  end
end
