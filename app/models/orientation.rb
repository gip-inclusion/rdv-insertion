class Orientation < ApplicationRecord
  belongs_to :user
  belongs_to :organisation
  belongs_to :orientation_type
  belongs_to :agent, optional: true

  validates :starts_at, presence: true

  validates :starts_at, :ends_at, uniqueness: { scope: :user_id }

  validate :ends_at_after_starts_at, :starts_at_in_the_past

  scope :active, -> { where("starts_at <= ? AND (ends_at IS NULL OR ends_at >= ?)", Time.zone.today, Time.zone.today) }

  def time_range
    starts_at...(ends_at.presence || Time.zone.today)
  end

  def current?
    ends_at.nil?
  end

  def active?
    time_range.cover?(Time.zone.today)
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
end
