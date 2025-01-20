module HasParticipationsToRdvs
  extend ActiveSupport::Concern

  def last_created_participation
    participations.max_by(&:created_at)
  end

  def seen_participations
    participations.to_a.select(&:seen?)
  end

  def last_seen_participation
    seen_participations.max_by(&:starts_at)
  end

  def seen_rdvs
    seen_participations.map(&:rdv).uniq
  end

  def first_seen_rdv
    seen_rdvs.min_by(&:starts_at)
  end

  def first_seen_rdv_starts_at
    first_seen_rdv&.starts_at
  end

  def first_rdv_creation_date
    rdvs.min_by(&:created_at).created_at
  end

  def first_participation_creation_date
    participations.min_by(&:created_at).created_at
  end

  def last_rdv
    rdvs.to_a.max_by(&:starts_at)
  end

  def last_rdv_starts_at
    last_rdv&.starts_at
  end

  def rdvs?
    rdvs.any?
  end

  def seen_rdvs?
    seen_rdvs.any?
  end
end
