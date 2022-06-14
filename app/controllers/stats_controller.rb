class StatsController < ApplicationController
  skip_before_action :authenticate_agent!, only: [:index, :show, :deployment_map]
  before_action :set_department, only: [:show]

  def index
    @department_count = Department.count
    collect_datas_for_stats
    set_stats_datas
  end

  def show
    @applicants = @department.applicants.preload(rdv_contexts: [:rdvs])
    @agents = @department.agents
    @invitations = @department.invitations
    @rdvs = @department.rdvs
    @rdv_contexts = @department.rdv_contexts.preload(:rdvs, :invitations)
    @organisations = @department.organisations
    # We don't display all stats for Yonne
    @display_all_stats = @department.configurations.none?(&:notify_applicant?)
    set_stats_datas
  end

  def deployment_map; end

  private

  def set_department
    @department = Department.includes(organisations: [:rdvs, :applicants, :invitations, :agents])
                            .find(params[:id])
  end

  def set_stats_datas
    @stats = Stat.new(applicants: @applicants, agents: @agents, invitations: @invitations,
                      rdvs: @rdvs, rdv_contexts: @rdv_contexts, organisations: @organisations)
  end

  def collect_datas_for_stats
    @organisations = Organisation.all
    @applicants = Applicant.includes(:rdvs).all.preload(rdv_contexts: :rdvs)
    @agents = Agent.all
    @invitations = Invitation.all
    @rdvs = Rdv.all
    @rdv_contexts = RdvContext.all.preload(:rdvs, :invitations)
  end
end
