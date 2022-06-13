module Stats
  class CreateStat < BaseService
    def initialize(department_id:)
      @department_id = department_id
    end

    def call
      collect_datas_for_stats
      save_record!(stat)
    end

    private

    def stat
      @stat ||= Stat.new(department_id: @department_id, **stats_data)
    end

    def stats_data
      @stats_data ||= ComputeStats.call(
        applicants: @applicants,
        agents: @agents,
        invitations: @invitations,
        rdvs: @rdvs,
        rdv_contexts: @rdv_contexts,
        organisations: @organisations
      )
    end

    def department
      @department ||= Department.includes(organisations: [:rdvs, :applicants, :invitations, :agents])
                                .find(@department_id)
    end

    def collect_datas_for_stats
      if department.present?
        collect_datas_for_department_stats
      else
        collect_datas_for_general_stats
      end
    end

    def collect_datas_for_general_stats
      @applicants = Applicant.all.preload(rdv_contexts: :rdvs)
      @agents = Agent.all
      @invitations = Invitation.all
      @rdvs = Rdv.all
      @rdv_contexts = RdvContext.all.preload(:rdvs, :invitations)
      @organisations = Organisation.all
    end

    def collect_datas_for_department_stats
      @applicants = department.applicants.preload(rdv_contexts: [:rdvs])
      @agents = department.agents
      @invitations = department.invitations
      @rdvs = department.rdvs
      @rdv_contexts = department.rdv_contexts.preload(:rdvs, :invitations)
      @organisations = department.organisations
    end
  end
end
