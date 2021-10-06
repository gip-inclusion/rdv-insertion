class Invitation < ApplicationRecord
  belongs_to :applicant
  delegate :department, to: :applicant

  enum format: { sms: 0, email: 1, link_only: 2 }

  def send_to_applicant
    case self.format
    when "sms"
      Invitations::SendSms.call(invitation: self)
    when "email"
      Invitations::SendEmail.call(invitation: self)
    end
  end

  def as_json(_opts = {})
    super.merge(sent_at: sent_at&.to_date&.strftime("%d/%m/%Y"))
  end
end
