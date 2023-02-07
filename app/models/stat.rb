class Stat < ApplicationRecord
  validates :department_number, presence: true

  def department
    @department ||= Department.find_by(number: department_number) if department_number != "all"
  end

  def all_applicants
    @all_applicants ||= department.nil? ? Applicant.all : department.applicants
  end

  def all_participations
    @all_participations ||= department.nil? ? Participation.all : department.participations
  end

  def invitations_sample
    @invitations_sample ||= department.nil? ? Invitation.sent : Invitation.sent.where(department_id: department.id)
  end

  # We filter the participations to only keep the rdvs/participations of the applicants in the scope
  def participations_sample
    @participations_sample ||= all_participations.preload(:rdv).where(applicant_id: applicants_sample).distinct
  end

  # We filter the rdvs to keep the rdvs of the applicants in the scope
  def rdvs_sample
    @rdvs_sample ||= Rdv.joins(:applicants).where(applicants: applicants_sample).distinct
  end

  # We exclude the rdvs collectifs motifs to correctly compute the rate of autonomous applicants
  def rdvs_non_collectifs_sample
    @rdvs_non_collectifs_sample ||= rdvs_sample.where(motif: Motif.not_collectif).distinct
  end

  def applicants_with_rdvs_non_collectifs_sample
    @applicants_with_rdvs_non_collectifs_sample ||= \
      Applicant.where(participations: participations_sample.where(rdv: rdvs_non_collectifs_sample)).distinct
  end

  # We filter the rdv_contexts to keep those where the applicants were invited and created a rdv/participation
  def rdv_contexts_sample
    @rdv_contexts_sample ||= RdvContext.preload(:participations, :invitations)
                                       .where(applicant_id: applicants_sample)
                                       .where.associated(:participations)
                                       .with_sent_invitations
                                       .distinct
  end

  # We filter the applicants by organisations and retrieve deleted or archived applicants
  def applicants_sample
    @applicants_sample ||= Applicant.includes(:participations)
                                    .preload(rdv_contexts: :participations)
                                    .joins(:organisations)
                                    .where(organisations: organisations_sample)
                                    .active
                                    .archived(false)
                                    .distinct
  end

  # We don't include in the stats the agents working for rdv-insertion
  def agents_sample
    @agents_sample ||= Agent.not_betagouv
                            .joins(:organisations)
                            .where(organisations: all_organisations)
                            .where(has_logged_in: true)
                            .distinct
  end

  def all_organisations
    @all_organisations ||= \
      department.nil? ? Organisation.all : department.organisations
  end

  # We don't include in the scope the organisations who don't invite the applicants
  def organisations_sample
    @organisations_sample ||= all_organisations.joins(:configurations)
                                               .where.not(configurations: { invitation_formats: [] })
  end

  # For the rate of applicants with rdv seen in less than 30 days
  # we only consider specific contexts to focus on the first RSA rdv
  def applicants_for_30_days_rdvs_seen_sample
    # Applicants with a right open since at least 30 days
    # & invited in an orientation or accompagnement context
    @applicants_for_30_days_rdvs_seen_sample ||= \
      applicants_sample.joins(:rdv_contexts)
                       .where(rdv_contexts:
                                RdvContext.joins(:motif_category).where(
                                  motif_category: { short_name: %w[
                                    rsa_orientation rsa_orientation_on_phone_platform rsa_accompagnement
                                    rsa_accompagnement_social rsa_accompagnement_sociopro
                                  ] }
                                ))
  end
end
