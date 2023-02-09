class Notification < ApplicationRecord
  include Sendable
  include Templatable

  belongs_to :participation, optional: true

  enum event: { participation_created: 0, participation_updated: 1, participation_cancelled: 2 }
  enum format: { sms: 0, email: 1 }

  validates :format, :event, :rdv_solidarites_rdv_id, presence: true

  delegate :applicant, :rdv, :motif_category, to: :participation
  delegate :template, to: :motif_category
  delegate :organisation, to: :rdv, allow_nil: true
  delegate :messages_configuration, to: :organisation

  # we assume a convocation is a notification of a created participation
  scope :convocations, -> { where(event: "participation_created") }
  scope :sent, -> { where.not(sent_at: nil) }

  def send_to_applicant
    case format
    when "sms"
      Notifications::SendSms.call(notification: self)
    when "email"
      Notifications::SendEmail.call(notification: self)
    end
  end
end
