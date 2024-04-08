class Notification < ApplicationRecord
  include HasCurrentConfiguration
  include Templatable
  include Sendable

  attr_accessor :content

  belongs_to :participation, optional: true

  enum event: {
    participation_created: "participation_created",
    participation_updated: "participation_updated",
    participation_cancelled: "participation_cancelled",
    participation_reminder: "participation_reminder"
  }
  enum format: { sms: "sms", email: "email", postal: "postal" }, _prefix: true

  validates :format, :event, :rdv_solidarites_rdv_id, presence: true

  delegate :department, :user, :rdv, :motif_category, :instruction_for_rdv, :rdv_context, to: :participation
  delegate :organisation, to: :rdv, allow_nil: true
  delegate :messages_configuration, :configurations, to: :organisation

  def send_to_user
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
