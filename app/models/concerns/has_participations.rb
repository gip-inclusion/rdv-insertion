module HasParticipations
  def last_created_participation
    participations.max_by(&:created_at)
  end

  def seen_participations
    participations.to_a.select(&:seen?)
  end
end
