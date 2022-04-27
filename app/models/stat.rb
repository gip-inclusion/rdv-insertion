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

  # Filtrage des rdvs en fonction des bénéficiaires dans le scope
  def relevant_rdvs
    @relevant_rdvs ||= rdvs.joins(:applicants).where(applicants: relevant_applicants)
  end

  def relevant_rdv_contexts
    @relevant_rdv_contexts ||= rdv_contexts.where(applicant_id: relevant_applicants.pluck(:id))
  end

  # --------------- Calcul du taux de bénéficiaires orientés en - de 30 jours ---------------
  def percentage_of_applicants_oriented_in_time
    (applicants_oriented_in_less_than_30_days.length / (
      applicants_with_at_least_30_days_seniority.length.nonzero? || 1
    ).to_f) * 100
  end

  def applicants_oriented_in_less_than_30_days
    applicants_with_at_least_30_days_seniority.to_a.select do |applicant|
      applicant.oriented? && applicant.orientation_delay_in_days < 30
    end
  end

  def applicants_with_at_least_30_days_seniority
    # Remove from calculation applicants that are not oriented yet and
    # were created less than 30 days ago
    relevant_applicants.where("rights_opening_date < ?", 30.days.ago)
                       .or(applicants.where(rights_opening_date: nil)
                                     .where("applicants.created_at < ?", 27.days.ago))
  end
  # -----------------------------------------------------------------------------------------

  def average_invitation_delay_in_days
    cumulated_invitation_delays = 0
    rdv_contexts_with_rdvs = relevant_rdv_contexts.includes(:rdvs).where.not(rdvs: {id: nil})

    rdv_contexts_with_rdvs.to_a.each do |rdv_context|
      cumulated_invitation_delays += rdv_context.invitation_delay_in_days
    end

    cumulated_invitation_delays / (rdv_contexts_with_rdvs.length.nonzero? || 1).to_f
  end

  def average_rdv_delay_in_days
    cumulated_rdv_delays = 0

    relevant_rdvs.to_a.each do |rdv|
      cumulated_rdv_delays += rdv.delay_in_days
    end

    cumulated_rdv_delays / (relevant_rdvs.length.nonzero? || 1).to_f
  end

  def percentage_of_no_show
    (relevant_rdvs.noshow.length / (relevant_rdvs.resolved.length.nonzero? || 1).to_f) * 100
  end

  def sent_invitations
    invitations.where.not(sent_at: nil).uniq(&:applicant_id)
  end
end
