class StatsController < ApplicationController
  skip_before_action :authenticate_agent!, only: [:index]
  before_action :collect_datas

  def index
    @stats = Stat.new(applicants: @applicants, agents: @agents, invitations: @invitations,
                      organisations: @organisations, rdvs: @rdvs)
  end

  def collect_datas
    @department_number = params[:department_number]
    if @department_number.present?
      scope_stats_to_department
    else
      @rdvs = Rdv.all
      @applicants = Applicant.all
      @invitations = Invitation.all
      @agents = Agent.all
      @organisations = Organisation.all
    end
  end

  def scope_stats_to_department
    @applicants = Applicant.joins(organisations: :department)
                           .where(organisations: { departments: { number: @department_number } })
    @agents = Agent.joins(organisations: :department)
                   .where(organisations: { departments: { number: @department_number } })
    @invitations = Invitation.joins(organisations: :department)
                             .where(organisations: { departments: { number: @department_number } })
    @rdvs = Rdv.joins(organisation: :department)
               .where(organisations: { departments: { number: @department_number } })
    @organisations = Organisation.joins(:department)
                                 .where(departments: { number: @department_number })
  end
end
