class Invitation < ApplicationRecord
  belongs_to :applicant
  delegate :department, to: :applicant

  enum format: { sms: 0, email: 1, link_only: 2 }
  after_commit :set_applicant_status

  def send_to_applicant
    case self.format
    when "sms"
      Invitations::SendSms.call(invitation: self)
    when "email"
      # next step
      # Invitations::SendEmail.call(invitation: self)
    end
  end

  def as_json(_opts = {})
    super.merge(sent_at: sent_at&.to_date&.strftime("%d/%m/%Y"))
  end

  private

  def set_applicant_status
    RefreshApplicantStatusesJob.perform_async(applicant.id)
  end
end
