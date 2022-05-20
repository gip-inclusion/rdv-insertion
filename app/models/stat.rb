# rubocop:disable Metrics/ClassLength

class Stat
  include ActiveModel::Model

  attr_accessor :applicants, :invitations, :agents, :organisations, :rdvs, :rdv_contexts

  # We don't include in the scope the organisations who don't invite the applicants
  def relevant_organisations
    @relevant_organisations ||= organisations
                                .includes(:applicants, :rdvs)
                                .joins(:configurations)
                                .where(configurations: { notify_applicant: false })
  end

  # We filter the applicants by organisations and retrieve deleted or archived applicants
  def relevant_applicants
    @relevant_applicants ||= applicants
                             .joins(:organisations)
                             .where(organisations: relevant_organisations)
                             .where.not(status: %w[deleted])
                             .archived(false)
                             .distinct
  end

  # We don't include in the stats the agents working for rdv-insertion
  def relevant_agents
    agents.where.not("agents.email LIKE ?", "%beta.gouv.fr").uniq
  end

  # We filter the rdvs to keep the rdvs of the applicants in the scope
  def relevant_rdvs
    @relevant_rdvs ||= rdvs.joins(:applicants).where(applicants: relevant_applicants).distinct
  end

  # For the % of no show, the average rdv delay and the rate of applicants oriented in less than 30 days
  # we only consider the rdvs in the "rsa_orientation" contexts, because the other rdvs are not always
  # correctly informed by the organisations/ or are taken in the past (which mess up with the delays)
  def orientation_rdvs
    @orientation_rdvs ||= relevant_rdvs.joins(:rdv_contexts)
                                       .where(rdv_contexts: { context: %w[rsa_orientation] })
  end

  def orientation_rdvs_by_month
    @orientation_rdvs_by_month ||= orientation_rdvs.group_by { |m| m.created_at.beginning_of_month }
  end

  def relevant_rdv_contexts
    @relevant_rdv_contexts ||= rdv_contexts.where(applicant_id: relevant_applicants.pluck(:id))
                                           .where.associated(:rdvs)
                                           .with_sent_invitations
                                           .distinct
  end

  def sent_invitations
    invitations.where.not(sent_at: nil)
  end

  # ----------------- Delays between the first invitation and the first rdv -----------------
  def average_time_between_invitation_and_rdv_in_days
    compute_average_time_between_invitation_and_rdv_in_days(relevant_rdv_contexts)
  end

  def average_time_between_invitation_and_rdv_in_days_by_month
    cumulated_invitation_delays_by_month = {}
    rdv_contexts_by_month = relevant_rdv_contexts.group_by { |m| m.created_at.beginning_of_month }
    rdv_contexts_by_month.each do |date, rdv_contexts|
      result = compute_average_time_between_invitation_and_rdv_in_days(rdv_contexts)
      cumulated_invitation_delays_by_month[date.strftime("%m/%Y")] = result.round
    end
    cumulated_invitation_delays_by_month
  end

  def compute_average_time_between_invitation_and_rdv_in_days(selected_rdv_contexts)
    cumulated_invitation_delays = 0
    selected_rdv_contexts.to_a.each do |rdv_context|
      cumulated_invitation_delays += rdv_context.time_between_invitation_and_rdv_in_days
    end
    cumulated_invitation_delays / (selected_rdv_contexts.count.nonzero? || 1).to_f
  end
  # -----------------------------------------------------------------------------------------

  # --------------- Delays between the creation of the rdvs and the rdvs date ---------------
  def average_time_between_rdv_creation_and_start_in_days
    compute_average_time_between_rdv_creation_and_start_in_days(orientation_rdvs)
  end

  def average_time_between_rdv_creation_and_start_in_days_by_month
    cumulated_time_between_rdv_creation_and_starts_by_month = {}
    orientation_rdvs_by_month.each do |date, rdvs|
      result = compute_average_time_between_rdv_creation_and_start_in_days(rdvs)
      cumulated_time_between_rdv_creation_and_starts_by_month[date.strftime("%m/%Y")] = result.round
    end
    cumulated_time_between_rdv_creation_and_starts_by_month
  end

  def compute_average_time_between_rdv_creation_and_start_in_days(selected_rdvs)
    cumulated_time_between_rdv_creation_and_starts = 0
    selected_rdvs.to_a.each do |rdv|
      cumulated_time_between_rdv_creation_and_starts += rdv.delay_in_days
    end
    cumulated_time_between_rdv_creation_and_starts / (selected_rdvs.count.nonzero? || 1).to_f
  end
  # -----------------------------------------------------------------------------------------

  # -------------------------------- Percentages of no show ---------------------------------
  def percentage_of_no_show
    compute_percentage_of_no_show(orientation_rdvs)
  end

  def percentage_of_no_show_by_month
    percentage_of_no_show_by_month = {}
    orientation_rdvs_by_month.each do |date, rdvs|
      result = compute_percentage_of_no_show(rdvs)
      percentage_of_no_show_by_month[date.strftime("%m/%Y")] = result.round
    end
    percentage_of_no_show_by_month
  end

  def compute_percentage_of_no_show(selected_rdvs)
    (selected_rdvs.count(&:noshow?) / (selected_rdvs.count(&:resolved?).nonzero? || 1).to_f) * 100
  end
  # -----------------------------------------------------------------------------------------

  # -------------------- Rate of applicants oriented in less than 30 days -------------------
  def percentage_of_applicants_oriented_in_less_than_30_days
    compute_percentage_of_applicants_oriented_in_less_than_30_days(applicants_for_30_days_orientation_scope)
  end

  def percentage_of_applicants_oriented_in_less_than_30_days_by_month
    percentage_of_applicants_oriented_in_less_than_30_days_by_month = {}
    applicants_by_month = applicants_for_30_days_orientation_scope.group_by { |m| m.created_at.beginning_of_month }

    applicants_by_month.each do |date, applicants|
      result = compute_percentage_of_applicants_oriented_in_less_than_30_days(applicants)
      percentage_of_applicants_oriented_in_less_than_30_days_by_month[date.strftime("%m/%Y")] = result.round
    end
    percentage_of_applicants_oriented_in_less_than_30_days_by_month
  end

  def compute_percentage_of_applicants_oriented_in_less_than_30_days(selected_applicants)
    (applicants_oriented_in_less_than_30_days(selected_applicants).count / (
      selected_applicants.count.nonzero? || 1
    ).to_f) * 100
  end

  def applicants_oriented_in_less_than_30_days(selected_applicants)
    selected_applicants.to_a.select do |applicant|
      applicant.oriented? && applicant.orientation_delay_in_days < 30
    end
  end

  def applicants_for_30_days_orientation_scope
    # Bénéficiaires avec dont le droit est ouvert depuis 30 jours au moins
    # et qui ont été invités dans un contexte d'orientation
    relevant_applicants.where("rights_opening_date < ?", 30.days.ago)
                       .or(relevant_applicants.where(rights_opening_date: nil)
                                     .where("applicants.created_at < ?", 27.days.ago))
                       .joins(:rdv_contexts)
                       .where(rdv_contexts: {
                                context: %w[rsa_orientation]
                              })
  end
  # -----------------------------------------------------------------------------------------
end

# rubocop: enable Metrics/ClassLength
