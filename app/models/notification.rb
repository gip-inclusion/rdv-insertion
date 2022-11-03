class Notification < ApplicationRecord
  include Sendable
  include Templatable

  belongs_to :applicant
  belongs_to :rdv, optional: true

  enum event: { rdv_created: 0, rdv_updated: 1, rdv_cancelled: 2 }
  enum format: { sms: 0, email: 1 }

  validates :format, :event, presence: true

  delegate :organisation, :motif_category, to: :rdv, allow_nil: true
  delegate :messages_configuration, to: :organisation

  # we assume a convocation is a notification of a created rdv
  scope :convocations, -> { where(event: "rdv_created") }
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
