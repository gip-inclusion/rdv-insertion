class Notification < ApplicationRecord
  include Sendable
  include Templatable

  attr_accessor :content

  belongs_to :participation, optional: true

  enum event: {
    participation_created: 0, participation_updated: 1, participation_cancelled: 2, participation_reminder: 3
  }
  enum format: { sms: 0, email: 1, postal: 2 }, _prefix: true

  validates :format, :event, :rdv_solidarites_rdv_id, presence: true

  delegate :department, :applicant, :rdv, :motif_category, :instruction_for_rdv, to: :participation
  delegate :organisation, to: :rdv, allow_nil: true
  delegate :messages_configuration, :configurations, to: :organisation

  scope :sent, -> { where.not(sent_at: nil) }

  def send_to_applicant
    case format
    when "sms"
      Notifications::SendSms.call(notification: self)
    when "email"
      Notifications::SendEmail.call(notification: self)
    when "postal"
      Notifications::GenerateLetter.call(notification: self)
    end
  end
end
