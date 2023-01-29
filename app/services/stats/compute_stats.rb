# rubocop:disable Metrics/ClassLength

module Stats
  class ComputeStats < BaseService
    def initialize(department_number:, current_stat:)
      @department_number = department_number
      @current_stat = current_stat
    end

    def call
      result.data = stat_attributes
    end

    private

    def stat_attributes
      @stat_attributes ||= {
        department_number: @department_number,
        applicants_count: applicants_count,
        applicants_count_grouped_by_month: applicants_count_grouped_by_month,
        rdvs_count: rdvs_count,
        rdvs_count_grouped_by_month: rdvs_count_grouped_by_month,
        sent_invitations_count: sent_invitations_count,
        sent_invitations_count_grouped_by_month: sent_invitations_count_grouped_by_month,
        percentage_of_no_show: percentage_of_no_show,
        percentage_of_no_show_grouped_by_month: percentage_of_no_show_grouped_by_month,
        average_time_between_invitation_and_rdv_in_days: average_time_between_invitation_and_rdv_in_days,
        average_time_between_invitation_and_rdv_in_days_by_month:
          average_time_between_invitation_and_rdv_in_days_by_month,
        average_time_between_rdv_creation_and_start_in_days: average_time_between_rdv_creation_and_start_in_days,
        average_time_between_rdv_creation_and_start_in_days_by_month:
          average_time_between_rdv_creation_and_start_in_days_by_month,
        rate_of_applicants_with_rdv_seen_in_less_than_30_days:
          rate_of_applicants_with_rdv_seen_in_less_than_30_days,
        rate_of_applicants_with_rdv_seen_in_less_than_30_days_by_month:
          rate_of_applicants_with_rdv_seen_in_less_than_30_days_by_month,
        rate_of_autonomous_applicants: rate_of_autonomous_applicants,
        rate_of_autonomous_applicants_grouped_by_month:
          rate_of_autonomous_applicants_grouped_by_month,
        agents_count: agents_count
      }
    end

    def created_last_month(data)
      data.where(created_at: 1.month.ago.all_month)
    end

    def department
      @department ||= Department.find_by(number: @department_number) if @department_number != "all"
    end

    def organisations
      @organisations ||= \
        department.nil? ? Organisation.all : department.organisations
    end

    def all_applicants
      @all_applicants ||= \
        department.nil? ? Applicant.all : department.applicants
    end

    def applicants_count
      all_applicants.to_a.length
    end

    def applicants_count_grouped_by_month
      @current_stat.applicants_count_grouped_by_month.merge(
        { 1.month.ago.strftime("%m/%Y") =>
          created_last_month(all_applicants).count }
      )
    end

    def all_rdvs
      @all_rdvs ||= \
        department.nil? ? Rdv.all : department.rdvs
    end

    def rdvs_count
      all_rdvs.to_a.length
    end

    def rdvs_count_grouped_by_month
      @current_stat.rdvs_count_grouped_by_month.merge(
        { 1.month.ago.strftime("%m/%Y") =>
          created_last_month(all_rdvs).count }
      )
    end

    def sent_invitations_count
      sent_invitations.to_a.length
    end

    def sent_invitations_count_grouped_by_month
      @current_stat.sent_invitations_count_grouped_by_month.merge(
        { 1.month.ago.strftime("%m/%Y") =>
          sent_invitations.where(sent_at: 1.month.ago.all_month).count }
      )
    end

    def agents_count
      relevant_agents.to_a.length
    end

    # We don't include in the scope the organisations who don't invite the applicants
    def relevant_organisations
      @relevant_organisations ||= organisations
                                  .joins(:configurations)
                                  .where.not(configurations: { invitation_formats: [] })
    end

    # We filter the applicants by organisations and retrieve deleted or archived applicants
    def relevant_applicants
      @relevant_applicants ||= Applicant
                               .includes(:rdvs)
                               .preload(rdv_contexts: :rdvs)
                               .joins(:organisations)
                               .where(organisations: relevant_organisations)
                               .active
                               .archived(false)
                               .distinct
    end

    # We don't include in the stats the agents working for rdv-insertion
    def relevant_agents
      @relevant_agents ||= Agent
                           .not_betagouv
                           .joins(:organisations)
                           .where(organisations: organisations)
                           .where(has_logged_in: true)
                           .distinct
    end

    # We filter the rdvs to keep the rdvs of the applicants in the scope
    def relevant_rdvs
      @relevant_rdvs ||= Rdv.joins(:applicants).where(applicants: relevant_applicants).distinct
    end

    # For the % of no show, the average rdv delay and the rate of applicants with rdv seen in less than 30 days
    # we only consider the rdvs in the "rsa_orientation" contexts, because the other rdvs are not always
    # correctly informed by the organisations/ or are taken in the past (which mess up with the delays)
    def orientation_rdvs
      @orientation_rdvs ||= relevant_rdvs.joins(:rdv_contexts)
                                         .where(rdv_contexts: { motif_category: %w[rsa_orientation] })
    end

    def orientation_rdvs_created_last_month
      @orientation_rdvs_created_last_month ||= \
        created_last_month(orientation_rdvs)
    end

    def relevant_rdv_contexts
      @relevant_rdv_contexts ||= RdvContext.preload(:rdvs, :invitations)
                                           .where(applicant_id: relevant_applicants.pluck(:id))
                                           .where.associated(:rdvs)
                                           .with_sent_invitations
                                           .distinct
    end

    def relevant_rdv_contexts_created_last_month
      @relevant_rdv_contexts_created_last_month ||= \
        created_last_month(relevant_rdv_contexts)
    end

    def sent_invitations
      @sent_invitations ||= \
        department.nil? ? Invitation.sent : Invitation.sent.where(department_id: department.id)
    end

    # ----------------- Delays between the first invitation and the first rdv -----------------
    def average_time_between_invitation_and_rdv_in_days
      compute_average_time_between_invitation_and_rdv_in_days(relevant_rdv_contexts)
    end

    def average_time_between_invitation_and_rdv_in_days_by_month
      @current_stat.average_time_between_invitation_and_rdv_in_days_by_month.merge(
        { 1.month.ago.strftime("%m/%Y") =>
          compute_average_time_between_invitation_and_rdv_in_days(relevant_rdv_contexts_created_last_month).round }
      )
    end

    def compute_average_time_between_invitation_and_rdv_in_days(selected_rdv_contexts)
      cumulated_invitation_delays = 0
      selected_rdv_contexts.to_a.each do |rdv_context|
        cumulated_invitation_delays += rdv_context.time_between_invitation_and_rdv_in_days
      end
      cumulated_invitation_delays / (selected_rdv_contexts.to_a.length.nonzero? || 1).to_f
    end
    # -----------------------------------------------------------------------------------------

    # --------------- Delays between the creation of the rdvs and the rdvs date ---------------
    def average_time_between_rdv_creation_and_start_in_days
      compute_average_time_between_rdv_creation_and_start_in_days(orientation_rdvs)
    end

    def average_time_between_rdv_creation_and_start_in_days_by_month
      @current_stat.average_time_between_rdv_creation_and_start_in_days_by_month.merge(
        { 1.month.ago.strftime("%m/%Y") =>
          compute_average_time_between_rdv_creation_and_start_in_days(orientation_rdvs_created_last_month).round }
      )
    end

    def compute_average_time_between_rdv_creation_and_start_in_days(selected_rdvs)
      cumulated_time_between_rdv_creation_and_starts = 0
      selected_rdvs.to_a.each do |rdv|
        cumulated_time_between_rdv_creation_and_starts += rdv.delay_in_days
      end
      cumulated_time_between_rdv_creation_and_starts / (selected_rdvs.to_a.length.nonzero? || 1).to_f
    end
    # -----------------------------------------------------------------------------------------

    # -------------------------------- Percentages of no show ---------------------------------
    def percentage_of_no_show
      compute_percentage_of_no_show(orientation_rdvs)
    end

    def percentage_of_no_show_grouped_by_month
      @current_stat.percentage_of_no_show_grouped_by_month.merge(
        { 1.month.ago.strftime("%m/%Y") =>
          compute_percentage_of_no_show(orientation_rdvs_created_last_month).round }
      )
    end

    def compute_percentage_of_no_show(selected_rdvs)
      (selected_rdvs.count(&:noshow?) / (selected_rdvs.count(&:resolved?).nonzero? || 1).to_f) * 100
    end
    # -----------------------------------------------------------------------------------------

    # -------------------- Rate of applicants with rdv seen in less than 30 days -------------------
    def rate_of_applicants_with_rdv_seen_in_less_than_30_days
      compute_rate_of_applicants_with_rdv_seen_in_less_than_30_days(applicants_for_30_days_rdvs_seen_scope)
    end

    def rate_of_applicants_with_rdv_seen_in_less_than_30_days_by_month
      @current_stat.rate_of_applicants_with_rdv_seen_in_less_than_30_days_by_month.merge(
        { 1.month.ago.strftime("%m/%Y") =>
          compute_rate_of_applicants_with_rdv_seen_in_less_than_30_days(
            applicants_for_30_days_rdvs_seen_scope_created_last_month
          ).round }
      )
    end

    def compute_rate_of_applicants_with_rdv_seen_in_less_than_30_days(selected_applicants)
      (applicants_oriented_in_less_than_30_days(selected_applicants).to_a.length / (
        selected_applicants.to_a.length.nonzero? || 1
      ).to_f) * 100
    end

    def applicants_oriented_in_less_than_30_days(selected_applicants)
      selected_applicants.to_a.select do |applicant|
        applicant.rdv_seen_delay_in_days.present? && applicant.rdv_seen_delay_in_days < 30
      end
    end

    def applicants_for_30_days_rdvs_seen_scope_created_last_month
      @applicants_for_30_days_rdvs_seen_scope_created_last_month ||= \
        created_last_month(applicants_for_30_days_rdvs_seen_scope)
    end

    def applicants_for_30_days_rdvs_seen_scope
      # Bénéficiaires avec dont le droit est ouvert depuis 30 jours au moins
      # et qui ont été invités dans un contexte d'orientation
      @applicants_for_30_days_rdvs_seen_scope ||= \
        relevant_applicants.where("applicants.created_at < ?", 30.days.ago)
                           .joins(:rdv_contexts)
                           .where(rdv_contexts: {
                                    motif_category: %w[
                                      rsa_orientation rsa_orientation_on_phone_platform rsa_accompagnement
                                      rsa_accompagnement_social rsa_accompagnement_sociopro
                                    ]
                                  })
    end
    # -----------------------------------------------------------------------------------------
    # ----------------------------- Rate of rdvs taken in autonomy ----------------------------

    def rate_of_autonomous_applicants
      compute_rate_of_autonomous_applicants(relevant_invited_applicants)
    end

    def rate_of_autonomous_applicants_grouped_by_month
      @current_stat.rate_of_applicants_with_rdv_seen_in_less_than_30_days_by_month.merge(
        { 1.month.ago.strftime("%m/%Y") =>
          compute_rate_of_autonomous_applicants(relevant_invited_applicants_created_last_month).round }
      )
    end

    def compute_rate_of_autonomous_applicants(selected_applicants)
      relevant_rdvs_created_by_user = relevant_rdvs.preload(:applicants).select(&:created_by_user?)
      autonomous_applicants = selected_applicants.select do |applicant|
        applicant.id.in?(relevant_rdvs_created_by_user.flat_map(&:applicant_ids))
      end
      (autonomous_applicants.count / (
        selected_applicants.count.nonzero? || 1
      ).to_f) * 100
    end

    def relevant_invited_applicants
      @relevant_invited_applicants ||= \
        relevant_applicants.where(id: sent_invitations.map(&:applicant_id).uniq)
    end

    def relevant_invited_applicants_created_last_month
      @relevant_invited_applicants_created_last_month ||= \
        created_last_month(relevant_invited_applicants)
    end
    # -----------------------------------------------------------------------------------------
  end
end

# rubocop: enable Metrics/ClassLength
