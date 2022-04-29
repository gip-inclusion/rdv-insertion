class StatsController < ApplicationController
  skip_before_action :authenticate_agent!, only: [:index]

  def index
    @deployment_map = params[:deployment_map] == "true"
    if params[:department_number].blank?
      collect_datas
    else
      filter_stats_by_department
    end
    @stats = Stat.new(applicants: @applicants, agents: @agents, invitations: @invitations,
                      rdvs: @rdvs, rdv_contexts: @rdv_contexts, organisations: @organisations)
  end

  private

  def collect_datas
    @organisations = Organisation.all
    @applicants = Applicant.includes(:rdvs, :rdv_contexts, :invitations).all
    @agents = Agent.all
    @invitations = Invitation.all
    @rdvs = Rdv.all
    @rdv_contexts = RdvContext.all
  end

  def filter_stats_by_department
    @department = Department.includes(organisations: [:rdvs, :applicants, :invitations, :agents])
                            .find_by!(number: params[:department_number])
    @applicants = @department.applicants.includes(:rdvs, :rdv_contexts, :invitations)
    @agents = @department.agents
    @invitations = @department.invitations
    @rdvs = @department.rdvs
    @rdv_contexts = @department.rdv_contexts

    @organisations = @department.organisations
    # We don't display all stats for Yonne
    @display_all_stats = @department.configurations.none?(&:notify_applicant?)
  end
end
