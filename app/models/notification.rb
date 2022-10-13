class Notification < ApplicationRecord
  include Sendable

  belongs_to :applicant
  belongs_to :rdv

  enum event: { rdv_created: 0, rdv_updated: 1, rdv_cancelled: 2 }
  enum format: { sms: 0, email: 1 }

  delegate :organisation, :motif_category, to: :rdv
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
