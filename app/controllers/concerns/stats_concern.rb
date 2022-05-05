module StatsConcern
  def set_stats_datas
    @stats = Stat.new(applicants: @applicants, agents: @agents, invitations: @invitations,
                      rdvs: @rdvs, rdv_contexts: @rdv_contexts, organisations: @organisations)
  end

  def collect_datas_for_stats
    @organisations = Organisation.all
    @applicants = Applicant.includes(:invitations, :rdvs, rdv_contexts: [:rdvs]).all
    @agents = Agent.all
    @invitations = Invitation.all
    @rdvs = Rdv.all
    @rdv_contexts = RdvContext.includes(:rdvs, :invitations).all
  end
end
