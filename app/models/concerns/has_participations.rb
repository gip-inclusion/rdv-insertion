module HasParticipations
  def last_created_participation
    participations.max_by(&:created_at)
  end

  def multiple_cancelled_participations?
    participations.select(&:cancelled_by_user?).length > 1
  end
end
