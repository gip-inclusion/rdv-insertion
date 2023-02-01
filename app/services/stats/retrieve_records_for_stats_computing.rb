module Stats
  class RetrieveRecordsForStatsComputing < BaseService
    def initialize(department_number:)
      @department_number = department_number
    end

    def call
      result.data = relevant_records
    end

    private

    def relevant_records
      @relevant_records ||= {
        all_applicants: all_applicants,
        all_rdvs: all_rdvs,
        sent_invitations: sent_invitations,
        relevant_rdvs: relevant_rdvs,
        relevant_rdv_contexts: relevant_rdv_contexts,
        relevant_applicants: relevant_applicants,
        relevant_agents: relevant_agents,
        relevant_organisations: relevant_organisations
      }
    end

    def all_applicants
      @all_applicants ||= \
        department.nil? ? Applicant.all : department.applicants
    end

    def all_rdvs
      @all_rdvs ||= \
        department.nil? ? Rdv.all : department.rdvs
    end

    def sent_invitations
      @sent_invitations ||= \
        department.nil? ? Invitation.sent : Invitation.sent.where(department_id: department.id)
    end

    # We filter the rdvs to keep the rdvs of the applicants in the scope
    def relevant_rdvs
      @relevant_rdvs ||= Rdv.joins(:applicants).where(applicants: relevant_applicants).distinct
    end

    def relevant_rdv_contexts
      @relevant_rdv_contexts ||= RdvContext.preload(:rdvs, :invitations)
                                           .where(applicant_id: relevant_applicants.pluck(:id))
                                           .where.associated(:rdvs)
                                           .with_sent_invitations
                                           .distinct
    end

    # We filter the applicants by organisations and retrieve deleted or archived applicants
    def relevant_applicants
      @relevant_applicants ||= Applicant.includes(:rdvs)
                                        .preload(rdv_contexts: :rdvs)
                                        .joins(:organisations)
                                        .where(organisations: relevant_organisations)
                                        .active
                                        .archived(false)
                                        .distinct
    end

    # We don't include in the stats the agents working for rdv-insertion
    def relevant_agents
      @relevant_agents ||= Agent.not_betagouv
                                .joins(:organisations)
                                .where(organisations: organisations)
                                .where(has_logged_in: true)
                                .distinct
    end

    def department
      @department ||= Department.find_by(number: @department_number) if @department_number != "all"
    end

    def organisations
      @organisations ||= \
        department.nil? ? Organisation.all : department.organisations
    end

    # We don't include in the scope the organisations who don't invite the applicants
    def relevant_organisations
      @relevant_organisations ||= organisations.joins(:configurations)
                                               .where.not(configurations: { invitation_formats: [] })
    end
  end
end
