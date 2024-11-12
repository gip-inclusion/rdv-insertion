module Organisation::Archivable
  extend ActiveSupport::Concern

  included do
    scope :active, -> { where(archived_at: nil) }
    scope :archived, -> { where.not(archived_at: nil) }
    validate :cannot_be_archived_if_agents_present, on: :update
  end

  def archived? = archived_at.present?

  def archive!
    update!(archived_at: Time.zone.now)
  end

  private

  def cannot_be_archived_if_agents_present
    errors.add(:archived_at, "Ne peut pas être archivée si des agents sont présents") if archived_at? && agents.any?
  end
end
