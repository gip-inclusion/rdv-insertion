class Notification < ApplicationRecord
  include HasCurrentCategoryConfiguration
  include Templatable
  include Sendable
  include Deliverable
  include HasSmsProvider

  attr_accessor :pdf_data

  belongs_to :participation

  enum :event, {
    participation_created: "participation_created",
    participation_updated: "participation_updated",
    participation_cancelled: "participation_cancelled",
    participation_reminder: "participation_reminder"
  }
  enum :format, { sms: "sms", email: "email", postal: "postal" }, prefix: true

  validates :format, :event, :rdv_solidarites_rdv_id, presence: true

  delegate :department, :user, :rdv, :motif_category, :instruction_for_rdv, :follow_up,
           to: :participation
  delegate :organisation, :motif, :agents, to: :rdv
  delegate :messages_configuration, :category_configurations, to: :organisation

  def display_agent_names?
    referents_related? && agents.any?
  end

  def agents_names
    agents.to_sentence if display_agent_names?
  end

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

  private

  def referents_related?
    motif.follow_up? || current_category_configuration&.rdv_with_referents?
  end
end
