module HasRdvsConcern
  extend ActiveSupport::Concern

  def first_seen_rdv
    rdvs.to_a.select(&:seen?).min_by(&:starts_at)
  end

  def first_seen_rdv_starts_at
    first_seen_rdv&.starts_at
  end

  def first_rdv_creation_date
    rdvs.min_by(&:created_at).created_at
  end

  def last_seen_rdv
    rdvs.to_a.select(&:seen?).max_by(&:starts_at)
  end

  def last_seen_rdv_starts_at
    last_seen_rdv&.starts_at
  end
end
