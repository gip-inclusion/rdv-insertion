class Stat < ApplicationRecord
  belongs_to :statable, polymorphic: true, optional: true

  def all_applicants
    @all_applicants ||= statable.nil? ? Applicant.all : statable.applicants
  end

  def archived_applicant_ids
    @archived_applicant_ids ||=
      if statable.nil?
        Applicant.where.associated(:archives).select(:id).ids
      else
        statable.archived_applicants.select(:id).ids
      end
  end

  def all_participations
    @all_participations ||= statable.nil? ? Participation.all : statable.participations
  end

  def invitations_sample
    @invitations_sample ||= statable.nil? ? Invitation.sent : statable.invitations.sent
  end

  # We filter the participations to only keep the participations of the applicants in the scope
  def participations_sample
    @participations_sample ||= all_participations.where(applicant_id: applicants_sample)
  end

  # We filter participations to keep only convocations
  def participations_with_notifications_sample
    @participations_with_notifications_sample ||= participations_sample.joins(:notifications).distinct
  end

  # We filter participations to keep only invitations
  def participations_without_notifications_sample
    @participations_without_notifications_sample ||= participations_sample.where.missing(:notifications).distinct
  end

  # We exclude the rdvs collectifs motifs to correctly compute the rate of autonomous applicants
  def rdvs_non_collectifs_sample
    @rdvs_non_collectifs_sample ||= Rdv.where(motif: Motif.individuel).distinct
  end

  def invited_applicants_with_rdvs_non_collectifs_sample
    @invited_applicants_with_rdvs_non_collectifs_sample ||=
      applicants_sample.joins(:rdvs)
                       .where(rdvs: rdvs_non_collectifs_sample)
                       .with_sent_invitations
                       .distinct
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
    @applicants_sample ||= Applicant.preload(:participations)
                                    .joins(:organisations)
                                    .where(organisations: organisations_sample)
                                    .active
                                    .where.not(id: archived_applicant_ids)
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
    @all_organisations ||=
      if statable_type == "Organisation"
        Organisation.where(id: statable_id)
      else
        statable.nil? ? Organisation.all : statable.organisations
      end
  end

  # We don't include in the scope the organisations who don't invite the applicants
  def organisations_sample
    @organisations_sample ||= all_organisations.joins(:configurations)
                                               .where.not(configurations: { invitation_formats: [] })
  end

  # For the rate of applicants with rdv seen in less than 30 days
  # we only consider specific contexts to focus on the first RSA rdv
  def applicants_for_30_days_rdvs_seen_sample
    # Applicants invited in an orientation or accompagnement context
    @applicants_for_30_days_rdvs_seen_sample ||=
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
