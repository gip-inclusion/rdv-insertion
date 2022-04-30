class Stat
  include ActiveModel::Model

  attr_accessor :applicants, :invitations, :agents, :organisations, :rdvs, :rdv_contexts

  # Les organisations qui n'invitent pas les bénéficiaires sont sorties du scope (par exemple, l'Yonne)
  def relevant_organisations
    @relevant_organisations ||= organisations
                                .includes(:applicants, :rdvs)
                                .joins(:configurations)
                                .where(configurations: { notify_applicant: false })
  end

  # Filtrage des bénéficiaires par organisations + les bénéficiaires supprimés ou archivés sont sortis du scope
  def relevant_applicants
    @relevant_applicants ||= applicants
                             .includes(:rdv_contexts)
                             .joins(:organisations)
                             .where(organisations: relevant_organisations)
                             .where.not(status: %w[deleted])
                             .where(is_archived: false)
  end

  # Ne pas inclure les agents correspondant aux membres de l'équipe rdv-insertion
  def relevant_agents
    agents.where.not("agents.email LIKE ?", "%beta.gouv.fr").uniq
  end

  # Filtrage des rdvs en fonction des bénéficiaires dans le scope
  def relevant_rdvs
    @relevant_rdvs ||= rdvs.joins(:applicants).where(applicants: relevant_applicants)
  end

  # Pour le % de no show, le délai de rdv moyen et le taux de bénéficiaires orientés en - de 30 jours
  # nous ne prenons que les rdvs des contextes "rsa_orientation" car les autres rdvs ne sont pas toujours
  # correctement renseignés par les départements/ ou sont pris dans le passé (ce qui fausse les délais)
  def orientation_rdvs
    @orientation_rdvs ||= relevant_rdvs.includes(:rdv_contexts)
                                       .where(rdv_contexts: {
                                                context: %w[rsa_orientation]
                                              })
  end

  def orientation_rdvs_by_month
    @orientation_rdvs_by_month ||= orientation_rdvs.group_by { |m| m.created_at.beginning_of_month }
  end

  def relevant_rdv_contexts
    @relevant_rdv_contexts ||= rdv_contexts.where(applicant_id: relevant_applicants.pluck(:id))
                                           .includes(:rdvs).where.not(rdvs: { id: nil })
  end

  def sent_invitations
    invitations.where.not(sent_at: nil)
  end

  # ------------ Calcul du délai entre la première invitation et le premier rdv -------------
  def average_invitation_delay_in_days
    compute_average_invitation_delay_in_days(relevant_rdv_contexts)
  end

  def average_invitation_delay_in_days_by_month
    cumulated_invitation_delays_by_month = {}
    rdv_contexts_by_month = relevant_rdv_contexts.group_by { |m| m.created_at.beginning_of_month }
    rdv_contexts_by_month.each do |date, rdv_contexts|
      result = compute_average_invitation_delay_in_days(rdv_contexts)
      cumulated_invitation_delays_by_month[date.strftime("%m/%Y")] = result.round
    end
    cumulated_invitation_delays_by_month
  end

  def compute_average_invitation_delay_in_days(selected_rdv_contexts)
    cumulated_invitation_delays = 0
    selected_rdv_contexts.to_a.each do |rdv_context|
      cumulated_invitation_delays += rdv_context.invitation_delay_in_days
    end
    cumulated_invitation_delays / (selected_rdv_contexts.count.nonzero? || 1).to_f
  end
  # -----------------------------------------------------------------------------------------

  # --------- Calcul du délai entre la date de création d'un rdv et la date du rdv ----------
  def average_rdv_delay_in_days
    compute_average_rdv_delay_in_days(orientation_rdvs)
  end

  def average_rdv_delay_in_days_by_month
    cumulated_rdv_delays_by_month = {}
    orientation_rdvs_by_month.each do |date, rdvs|
      result = compute_average_rdv_delay_in_days(rdvs)
      cumulated_rdv_delays_by_month[date.strftime("%m/%Y")] = result.round
    end
    cumulated_rdv_delays_by_month
  end

  def compute_average_rdv_delay_in_days(selected_rdvs)
    cumulated_rdv_delays = 0
    selected_rdvs.to_a.each do |rdv|
      cumulated_rdv_delays += rdv.delay_in_days
    end
    cumulated_rdv_delays / (selected_rdvs.count.nonzero? || 1).to_f
  end
  # -----------------------------------------------------------------------------------------

  # -------------------------------- Calcul du taux de lapin --------------------------------
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
    selected_rdvs = Rdv.where(id: selected_rdvs.map(&:id)) if selected_rdvs.is_a?(Array)
    (selected_rdvs.noshow.count / (selected_rdvs.resolved.count.nonzero? || 1).to_f) * 100
  end
  # -----------------------------------------------------------------------------------------

  # --------------- Calcul du taux de bénéficiaires orientés en - de 30 jours ---------------
  def percentage_of_applicants_oriented_in_time
    compute_percentage_of_applicants_oriented_in_time(applicants_for_30_days_orientation_scope)
  end

  def percentage_of_applicants_oriented_in_time_by_month
    percentage_of_applicants_oriented_in_time_by_month = {}
    applicants_by_month = applicants_for_30_days_orientation_scope.group_by { |m| m.created_at.beginning_of_month }

    applicants_by_month.each do |date, applicants|
      result = compute_percentage_of_applicants_oriented_in_time(applicants)
      percentage_of_applicants_oriented_in_time_by_month[date.strftime("%m/%Y")] = result.round
    end
    percentage_of_applicants_oriented_in_time_by_month
  end

  def compute_percentage_of_applicants_oriented_in_time(selected_applicants)
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
                       .includes(:rdv_contexts)
                       .where(rdv_contexts: {
                                context: %w[rsa_orientation]
                              })
  end
  # -----------------------------------------------------------------------------------------
end
