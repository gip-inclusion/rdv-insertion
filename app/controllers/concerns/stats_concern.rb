module StatsConcern
  def set_stats_datas
    @stats = Stat.new(applicants: @applicants, agents: @agents, invitations: @invitations,
                      rdvs: @rdvs, rdv_contexts: @rdv_contexts, organisations: @organisations)
  end

  def collect_datas_for_stats
    @organisations = Organisation.all
    @applicants = Applicant.includes(:invitations, :rdv_contexts, rdvs: [:rdv_contexts]).all
    @agents = Agent.all
    @invitations = Invitation.all
    @rdvs = Rdv.all
    @rdv_contexts = RdvContext.all.includes(:rdvs, :invitations)
  end

  def filter_stats_by_department
    @department = Department.includes(organisations: [:rdvs, :applicants, :invitations, :agents])
                            .find_by!(number: params[:department_number])
    @applicants = @department.applicants.includes(:rdvs, :rdv_contexts, :invitations)
    @agents = @department.agents
    @invitations = @department.invitations
    @rdvs = @department.rdvs
    @rdv_contexts = @department.rdv_contexts.includes(:rdvs, :invitations)

    @organisations = @department.organisations
    # We don't display all stats for Yonne
    @display_all_stats = @department.configurations.none?(&:notify_applicant?)
  end
end
