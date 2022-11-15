module HasRdvs
  extend ActiveSupport::Concern

  def seen_rdvs
    rdvs.joins(:participations).distinct.to_a.select { |participation| participation.status == "seen" }
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

  def last_seen_rdv
    seen_rdvs.max_by(&:starts_at)
  end

  def last_seen_rdv_starts_at
    last_seen_rdv&.starts_at
  end

  def last_rdv
    rdvs.to_a.max_by(&:starts_at)
  end

  def last_rdv_starts_at
    last_rdv&.starts_at
  end

  def rdvs?
    !rdvs.empty?
  end
end
