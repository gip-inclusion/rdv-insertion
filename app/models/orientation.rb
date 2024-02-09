class Orientation < ApplicationRecord
  belongs_to :user
  belongs_to :organisation
  belongs_to :agent, optional: true

  validates :starts_at, :orientation_type, presence: true

  validates :starts_at, :ends_at, uniqueness: { scope: :user_id }

  validate :ends_at_after_starts_at, :starts_at_in_the_past

  enum orientation_type: { social: 0, pro: 1, socio_pro: 2 }

  def time_range
    starts_at...(ends_at.presence || Time.zone.today)
  end

  def current?
    ends_at.nil?
  end

  private

  def ends_at_after_starts_at
    return if ends_at.nil?
    return if ends_at > starts_at

    errors.add(:base, "La date de fin doit être postérieure à la date de début")
  end

  def starts_at_in_the_past
    return if starts_at < Time.zone.today

    errors.add(:starts_at, "la date de début doit être antérieure à la date d'aujourd'hui")
  end
end
