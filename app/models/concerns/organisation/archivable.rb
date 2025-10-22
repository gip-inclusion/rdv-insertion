module Organisation::Archivable
  extend ActiveSupport::Concern

  included do
    scope :active, -> { where(archived_at: nil) }
    scope :archived, -> { where.not(archived_at: nil) }
    validate :cannot_be_archived_if_agents_present, on: :update
  end

  def archived? = archived_at.present?

  def archive!
    archived? || update!(archived_at: Time.zone.now, name: "[Organisation archivée] #{name}")
  end

  def unarchive!
    update!(archived_at: nil, name: name.gsub(/^\[Organisation archivée\] /, ""))
  end

  private

  def cannot_be_archived_if_agents_present
    errors.add(:archived_at, "Ne peut pas être archivée si des agents sont présents") if archived_at? && agents.any?
  end
end
