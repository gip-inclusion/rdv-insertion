class Invitation < ApplicationRecord
  belongs_to :applicant
  delegate :department, to: :applicant

  enum format: { sms: 0, email: 1, link_only: 2 }, _prefix: :format
  after_commit :set_applicant_status

  scope :sent_in_time_window, -> { where("sent_at > ?", Department::TIME_TO_ACCEPT_INVITATION.ago) }

  def send_to_applicant
    case self.format
    when "sms"
      Invitations::SendSms.call(invitation: self)
    when "email"
      Invitations::SendEmail.call(invitation: self)
    end
  end

  private

  def set_applicant_status
    RefreshApplicantStatusesJob.perform_async(applicant.id)
  end
end
