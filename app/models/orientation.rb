class Orientation < ApplicationRecord
  MINIMUM_DURATION_IN_DAYS = 7

  has_paper_trail

  belongs_to :user
  belongs_to :organisation
  belongs_to :orientation_type
  belongs_to :agent, optional: true

  validates :starts_at, presence: true

  validates :starts_at, uniqueness: { scope: :user_id }

  validate :ends_at_after_starts_at, :starts_at_in_the_past, :time_range_is_sufficiently_long

  # The end date of these orientations might be shrinked to the day before the start of the next one.
  # To ensure the duration of the orientation we shrink remains valid, we verify that its start date is at least:
  #  MINIMUM_DURATION_IN_DAYS + 1 days before its potentially adjusted end date.
  scope :shrinkeable_to_fit, lambda { |orientation|
    where(user_id: orientation.user_id)
      .where.not(id: orientation.id)
      .where("starts_at <= ? AND (ends_at IS NULL OR ends_at > ?)",
             orientation.starts_at - 1.day - Orientation::MINIMUM_DURATION_IN_DAYS.days,
             orientation.starts_at)
  }

  def time_range
    starts_at...(ends_at.presence || Time.zone.now)
  end

  def current?
    ends_at.nil?
  end

  def active?
    time_range.cover?(Time.zone.today.beginning_of_day)
  end

  private

  def ends_at_after_starts_at
    return if ends_at.nil?
    return if ends_at > starts_at

    errors.add(:base, "La date de fin doit être postérieure à la date de début")
  end

  def starts_at_in_the_past
    return if starts_at <= Time.zone.today

    errors.add(:starts_at, "la date de début doit être antérieure ou égale à la date d'aujourd'hui")
  end

  def time_range_is_sufficiently_long
    return if ends_at.nil?
    return if (ends_at - starts_at).to_i >= MINIMUM_DURATION_IN_DAYS

    errors.add(:base, "La période doit être d'au moins #{MINIMUM_DURATION_IN_DAYS} jours")
  end
end
