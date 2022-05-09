module StatsConcern
  def set_stats_datas
    @stats = Stat.new(applicants: @applicants, agents: @agents, invitations: @invitations,
                      rdvs: @rdvs, rdv_contexts: @rdv_contexts, organisations: @organisations)
  end

  def collect_datas_for_stats
    @organisations = Organisation.all
    @applicants = Applicant.all.includes(:rdvs, :invitations).preload(rdv_contexts: [:rdvs])
    @agents = Agent.all
    @invitations = Invitation.all
    @rdvs = Rdv.all
    @rdv_contexts = RdvContext.all.includes(:invitations).preload(:rdvs)
  end
end
