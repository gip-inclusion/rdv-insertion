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
    (applicants_oriented_in_less_than_30_days.count / (
      applicants_for_30_days_orientation_scope.count.nonzero? || 1
    ).to_f) * 100
  end

  def applicants_oriented_in_less_than_30_days
    applicants_for_30_days_orientation_scope.to_a.select do |applicant|
      applicant.oriented? && applicant.orientation_delay_in_days < 30
    end
  end

  def applicants_for_30_days_orientation_scope
    # Bénéficiaires avec dont le droit est ouvert depuis 30 jours au moins
    # et qui ont été invités dans un contexte d'orientation
    relevant_applicants.where("rights_opening_date < ?", 30.days.ago)
                       .or(applicants.where(rights_opening_date: nil)
                                     .where("applicants.created_at < ?", 27.days.ago))
                       .includes(:rdv_contexts)
                       .where(rdv_contexts: {
                                context: %w[rsa_orientation]
                              })
  end
  # -----------------------------------------------------------------------------------------

  # Pour le % de no show, le délai de rdv moyen et le taux de bénéficiaires orientés en - de 30 jours
  # nous ne prenons que les rdvs des contextes "rsa_orientation" car les autres rdvs ne sont pas toujours
  # correctement renseignés par les départements/ ou sont pris dans le passé (ce qui fausse les délais)
  def orientation_rdvs
    relevant_rdvs.includes(:rdv_contexts)
                 .where(rdv_contexts: {
                          context: %w[rsa_orientation]
                        })
  end

  def average_invitation_delay_in_days
    cumulated_invitation_delays = 0
    rdv_contexts_with_rdvs = relevant_rdv_contexts.includes(:rdvs).where.not(rdvs: { id: nil })

    rdv_contexts_with_rdvs.to_a.each do |rdv_context|
      cumulated_invitation_delays += rdv_context.invitation_delay_in_days
    end

    cumulated_invitation_delays / (rdv_contexts_with_rdvs.count.nonzero? || 1).to_f
  end

  def average_rdv_delay_in_days
    cumulated_rdv_delays = 0

    orientation_rdvs.to_a.each do |rdv|
      cumulated_rdv_delays += rdv.delay_in_days
    end

    cumulated_rdv_delays / (orientation_rdvs.count.nonzero? || 1).to_f
  end

  def percentage_of_no_show
    (orientation_rdvs.noshow.count / (orientation_rdvs.resolved.count.nonzero? || 1).to_f) * 100
  end

  def percentage_of_no_show_by_month
    rdv_month = orientation_rdvs.select(&:created_at).min_by(&:created_at).created_at.beginning_of_month
    percentage_of_no_show_by_month = {}

    while rdv_month < Time.zone.today
      orientation_rdvs_of_month = orientation_rdvs.where("rdvs.created_at >= ?", rdv_month)
                                                  .where("rdvs.created_at < ?", rdv_month + 1.month)
      number_of_orientation_rdvs_of_month_no_show = orientation_rdvs_of_month.noshow.count
      number_of_orientation_rdvs_of_month_resoved = orientation_rdvs_of_month.resolved.count
      percentage_of_no_show_of_month = (number_of_orientation_rdvs_of_month_no_show / (
        number_of_orientation_rdvs_of_month_resoved.nonzero? || 1
      ).to_f) * 100
      percentage_of_no_show_by_month[rdv_month.strftime("%m/%Y")] = percentage_of_no_show_of_month.round
      rdv_month += 1.month
    end
    percentage_of_no_show_by_month
  end

  def sent_invitations
    invitations.where.not(sent_at: nil)
  end
end
